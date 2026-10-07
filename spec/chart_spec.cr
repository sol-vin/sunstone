require "./spec_helper"
require "../src/sunstone/chart"

describe Sunstone::Chart do
  it "renders a Celestine SVG sparkline" do
    svg = Sunstone::Chart.sparkline([10.0, 20.0, 15.0, 30.0], stroke: "#38bdf8")
    svg.should contain("<svg")
    svg.should contain("sunstone-sparkline")
    svg.should contain("path")
  end

  it "renders a Celestine SVG progress ring" do
    svg = Sunstone::Chart.progress_ring(75.0, color: "#10b981")
    svg.should contain("<svg")
    svg.should contain("sunstone-progress-ring")
  end

  it "renders a Celestine SVG bar chart" do
    svg = Sunstone::Chart.bar_chart(["A", "B"], [10.0, 25.0], bar_color: "#38bdf8")
    svg.should contain("<svg")
    svg.should contain("sunstone-bar-chart")
    svg.should contain("rect")
    svg.should contain("A")
    svg.should contain("B")
  end

  it "renders from YAML configuration" do
    node = YAML.parse("type: bar\nlabels:\n  - A\n  - B\nvalues:\n  - 10\n  - 20\n")
    svg = Sunstone::Chart.from_yaml(node, "#38bdf8")
    svg.should_not be_nil
    svg.not_nil!.should contain("sunstone-bar-chart")
  end
end
