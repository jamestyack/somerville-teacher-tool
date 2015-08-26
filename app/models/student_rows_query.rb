class StudentRowsQuery < Struct.new :homeroom

  def student_attribute_rows
    sql = \
        <<-SQL
            SELECT
              students.id as student_id,
              race,
              first_name,
              last_name,
              grade,
              program_assigned,
              home_language,
              free_reduced_lunch,
              sped_placement,
              disability,
              sped_level_of_need,
              plan_504,
              limited_english_proficiency,
              level,
              explanation
            FROM 
                students as s
            LEFT JOIN student_risk_levels
              ON student_risk_levels.student_id = students.id
            WHERE homeroom_id = #{homeroom.id}
            ORDER BY
              level DESC NULLS LAST;
  SQL
    rows = []
    ActiveRecord::Base.connection.execute(sql).each do |row|
      rows << row
    end
    return rows
  end

  def student_assessment_rows
    sql = \
            " SELECT DISTINCT ON
              (students.id, assessments.family, assessments.subject)
              students.id as student_id,
              family,
              subject,
              scale_score,
              growth_percentile,
              percentile_rank,
              instructional_reading_level,
              performance_level,
              date_taken
            FROM students
            LEFT JOIN student_assessments
              ON student_assessments.student_id = students.id
            LEFT JOIN assessments
              ON student_assessments.assessment_id = assessments.id
            WHERE homeroom_id = #{homeroom.id}
            AND assessments.family
              IN ('MCAS', 'STAR', 'ACCESS', 'DIBELS')
            ORDER BY
              students.id,
              assessments.family,
              assessments.subject,
              student_assessments.date_taken DESC NULLS LAST;"
    rows = []
    ActiveRecord::Base.connection.execute(sql).each do |row|
      rows << row
    end
    return rows
  end

  def single_query
      <<-SQL
        select distinct 
            on (srl.level, s.id, a.family, a.subject)
            s.id,
            s.race,
            s.first_name,
            s.last_name,
            s.grade,
            s.program_assigned,
            s.home_language,
            s.free_reduced_lunch,
            s.sped_placement,
            s.disability,
            s.sped_level_of_need,
            s.plan_504,
            s.limited_english_proficiency,
            srl.level,
            srl.explanation,
            a.family,
            a.subject,
            sa.scale_score,
            sa.growth_percentile,
            sa.percentile_rank,
            sa.instructional_reading_level,
            sa.performance_level,
            sa.date_taken
        from
            students as s,
            assessments as a,
            student_assessments as sa,
            student_risk_levels as srl
        where
            s.id = sa.student_id and
            s.id = srl.student_id and
            sa.assessment_id = a.id and
            s.homeroom_id = 1 and
            a.family in ('MCAS', 'STAR', 'ACCESS', 'DIBELS')
        order by
            srl.level DESC NULLS LAST,
            s.id,
            a.family,
            a.subject,
            sa.date_taken DESC NULLS LAST;
      SQL
  end
end
