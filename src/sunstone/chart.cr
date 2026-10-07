require "celestine"
require "yaml"

module Sunstone
  module Chart
    # Generates a sparkline SVG using Celestine::DataViz
    def self.sparkline(
      data : Array(Float64),
      width : Int32 = 240,
      height : Int32 = 45,
      stroke : String = "#38bdf8",
      stroke_width : Float64 = 2.5,
      fill : String? = nil,
      smooth : Bool = true
    ) : String
      svg = Celestine::Svg.new
      svg.view_box(0, 0, width, height)
      svg.custom_attrs["class"] = "sunstone-chart sunstone-sparkline"
      svg.custom_attrs["preserveAspectRatio"] = "none"

      padding = 4.0
      x = padding
      y = padding
      w = width.to_f64 - (padding * 2.0)
      h = height.to_f64 - (padding * 2.0)

      svg.sparkline(data, x, y, w, h, stroke: stroke, stroke_width: stroke_width, fill: fill, smooth: smooth)
      svg.to_s
    end

    # Generates a circular progress ring SVG using Celestine::DataViz
    def self.progress_ring(
      progress : Float64,
      size : Int32 = 70,
      stroke_width : Float64 = 6.0,
      color : String = "#38bdf8",
      track_color : String = "rgba(255, 255, 255, 0.12)"
    ) : String
      svg = Celestine::Svg.new
      svg.view_box(0, 0, size, size)
      svg.custom_attrs["class"] = "sunstone-chart sunstone-progress-ring"

      center = size.to_f64 / 2.0
      radius = (size.to_f64 - stroke_width) / 2.0

      svg.progress_ring(
        cx: center,
        cy: center,
        radius: radius,
        progress: progress,
        track_color: track_color,
        fill_color: color,
        stroke_width: stroke_width
      )
      svg.to_s
    end

    # Generates a comparative bar chart SVG using Celestine
    def self.bar_chart(
      labels : Array(String),
      values : Array(Float64),
      width : Int32 = 480,
      height : Int32 = 220,
      bar_color : String = "#38bdf8",
      highlight_color : String = "#f59e0b",
      highlight_index : Int32? = nil
    ) : String
      svg = Celestine::Svg.new
      svg.view_box(0, 0, width, height)
      svg.custom_attrs["class"] = "sunstone-chart sunstone-bar-chart"

      return svg.to_s if values.empty?

      max_val = values.max
      max_val = 1.0 if max_val <= 0.0

      margin_bottom = 35.0
      margin_top = 22.0
      margin_left = 24.0
      margin_right = 24.0

      chart_w = width.to_f64 - margin_left - margin_right
      chart_h = height.to_f64 - margin_top - margin_bottom

      n = values.size
      bar_gap = 16.0
      bar_w = (chart_w - (bar_gap * (n - 1))) / n
      bar_w = 44.0 if bar_w > 64.0

      values.each_with_index do |val, idx|
        bar_h = (val / max_val) * chart_h
        bar_h = 2.0 if bar_h < 2.0
        bx = margin_left + idx * (bar_w + bar_gap)
        by = margin_top + chart_h - bar_h

        # Bar rectangle
        rect = Celestine::Rectangle.new
        rect.x = bx
        rect.y = by
        rect.width = bar_w
        rect.height = bar_h
        rect.radius_x = 4.0
        rect.radius_y = 4.0
        rect.fill = (highlight_index == idx) ? highlight_color : bar_color
        svg << rect

        # Value label on top of bar
        v_text = Celestine::Text.new
        v_text.x = bx + bar_w / 2.0
        v_text.y = by - 6.0
        v_text.text_anchor = "middle"
        v_text.font_size = 11.0
        v_text.font_family = "monospace"
        v_text.fill = "rgba(255, 255, 255, 0.9)"
        v_text.text = val >= 1000 ? "#{(val / 1000.0).round(1)}k" : (val == val.to_i ? val.to_i.to_s : val.round(1).to_s)
        svg << v_text

        # Category label below baseline
        if lbl = labels[idx]?
          c_text = Celestine::Text.new
          c_text.x = bx + bar_w / 2.0
          c_text.y = margin_top + chart_h + 18.0
          c_text.text_anchor = "middle"
          c_text.font_size = 11.0
          c_text.font_weight = "bold"
          c_text.fill = "rgba(255, 255, 255, 0.7)"
          c_text.text = lbl
          svg << c_text
        end
      end

      # Baseline
      baseline = Celestine::Line.new
      baseline.x1 = margin_left - 4.0
      baseline.y1 = margin_top + chart_h
      baseline.x2 = margin_left + chart_w + 4.0
      baseline.y2 = margin_top + chart_h
      baseline.stroke = "rgba(255, 255, 255, 0.2)"
      baseline.stroke_width = 1.0
      svg << baseline

      svg.to_s
    end

    # Convenience method to render an SVG chart from a YAML node
    def self.from_yaml(node : YAML::Any, default_color : String = "#38bdf8") : String?
      chart_type = node["chart_type"]?.try(&.as_s) || node["type"]?.try(&.as_s) || "sparkline"
      if chart_type == "chart" || chart_type == "svg_chart"
        chart_type = if node["labels"]? || node["values"]?
                       "bar"
                     elsif node["progress"]?
                       "ring"
                     else
                       "sparkline"
                     end
      end

      case chart_type
      when "sparkline", "line"
        data = Array(Float64).new
        if raw_data = node["data"]?.try(&.as_a)
          raw_data.each { |d| data << (d.as_f? || d.as_i?.try(&.to_f64) || 0.0) }
        end
        return nil if data.empty?

        w = node["width"]?.try(&.as_i) || 280
        h = node["height"]?.try(&.as_i) || 50
        stroke = node["color"]?.try(&.as_s) || default_color
        stroke_w = node["stroke_width"]?.try(&.as_f) || 2.5
        fill = node["fill"]?.try(&.as_s)
        smooth = node["smooth"]?.try(&.as_bool) != false
        sparkline(data, width: w, height: h, stroke: stroke, stroke_width: stroke_w, fill: fill, smooth: smooth)

      when "ring", "progress_ring", "donut"
        prog = node["progress"]?.try(&.as_f) || node["value"]?.try(&.as_f) || 0.0
        size = node["size"]?.try(&.as_i) || 72
        stroke_w = node["stroke_width"]?.try(&.as_f) || 6.0
        color = node["color"]?.try(&.as_s) || default_color
        track = node["track_color"]?.try(&.as_s) || "rgba(255, 255, 255, 0.12)"
        progress_ring(prog, size: size, stroke_width: stroke_w, color: color, track_color: track)

      when "bar", "bars", "bar_chart"
        labels = Array(String).new
        if raw_lbls = node["labels"]?.try(&.as_a)
          raw_lbls.each { |l| labels << l.as_s }
        end

        values = Array(Float64).new
        if raw_vals = node["values"]?.try(&.as_a) || node["data"]?.try(&.as_a)
          raw_vals.each { |v| values << (v.as_f? || v.as_i?.try(&.to_f64) || 0.0) }
        end
        return nil if values.empty?

        w = node["width"]?.try(&.as_i) || 480
        h = node["height"]?.try(&.as_i) || 220
        b_color = node["color"]?.try(&.as_s) || default_color
        hl_color = node["highlight_color"]?.try(&.as_s) || "#f59e0b"
        hl_idx = node["highlight_index"]?.try(&.as_i)
        bar_chart(labels, values, width: w, height: h, bar_color: b_color, highlight_color: hl_color, highlight_index: hl_idx)

      else
        nil
      end
    end
  end
end
