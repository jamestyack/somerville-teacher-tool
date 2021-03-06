(function(root) {

  var BehaviorChart = function initializeBehaviorChart (series, categories) {
    this.title = "behavior incidents";
    this.series = series;
    this.categories = categories;
  };

  BehaviorChart.fromChartData = function behaviorChartFromChartData (chartData) {
    var data = [
      new ProfileChartData("Behavior Incidents", chartData.data('behavior-series')).toChart()
    ];
    return new BehaviorChart(data, chartData.data('behavior-series-school-years'));
  };

  BehaviorChart.prototype.toHighChart = function behaviorChartToHighChart () {
    return $.extend({}, ChartSettings.base_options, {
      xAxis: $.extend({}, ChartSettings.x_axis_schoolyears, {
        categories: this.categories
      }),
      yAxis: ChartSettings.default_yaxis,
      series: this.series
    });
  };

  BehaviorChart.prototype.render = function renderBehaviorChart (controller) {
    controller.renderChartOrEmptyView(this);
  };

  root.BehaviorChart = BehaviorChart;

})(window)
