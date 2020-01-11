require "test_helper"

class ChicagoMapTest < ActiveSupport::TestCase
  test "runs with no data" do
    ChicagoMap.new({}).to_xml
  end

  test "adds styles to svg" do
    svg = <<~XML
      <svg xmlns="http://www.w3.org/2000/svg">
          <polygon id="100" />
          <polygon id="101" />
          <polygon id="102" />
      </svg>
    XML
    values = {
      100 => 0,
      101 => 22,
      103 => 30,
    }
    map = ChicagoMap.new(values, svg: svg, fill: "red")
    assert_equal <<~XML, map.to_xml
      <?xml version="1.0"?>
      <svg xmlns="http://www.w3.org/2000/svg">
          <polygon id="100" style="fill: red; fill-opacity: 0.0;"/>
          <polygon id="101" style="fill: red; fill-opacity: 0.7;"/>
          <polygon id="102"/>
      </svg>
    XML
  end

  test "style attribute generation" do
    assert_equal "fill: blue; fill-opacity: 0.5;", ChicagoMap.generate_style(5, 10, "blue")
    assert_equal "fill: blue; fill-opacity: 0.1;", ChicagoMap.generate_style(5, 100, "blue")
  end
end
