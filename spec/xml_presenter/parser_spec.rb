RSpec.describe XmlPresenter::Parser do
  context "with no configuration" do
    it "maps simple XML (with no multiples) to a hash structure" do
      xml = "<Opening><Node-1>value 1</Node-1><Node-2>value 2</Node-2></Opening>"
      expected = {
        "node_1" => "value 1",
        "node_2" => "value 2",
      }
      expect(described_class.new.parse(xml)).to eq expected
    end
  end

  context "with bases defined" do
    let(:parser) { described_class.new bases: %w[Base] }

    it "pulls up nodes under bases into same level as base" do
      xml = "<Root><Id>ID123</Id><Base><Node-1>value 1</Node-1><Node-2>value 2</Node-2></Base></Root>"
      expected = {
        "id" => "ID123",
        "node_1" => "value 1",
        "node_2" => "value 2",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with nodes excluded" do
    let(:parser) { described_class.new excludes: %w[Node-2] }

    it "excludes XML node names from mapping into output data structure" do
      xml = "<Root><Id>ID123</Id><Node-1>value 1</Node-1><Node-2>value 2</Node-2><Node-3>value 3</Node-3></Root>"
      expected = {
        "id" => "ID123",
        "node_1" => "value 1",
        "node_3" => "value 3",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with nodes included on top of excludes" do
    let(:parser) { described_class.new excludes: %w[Exclude], includes: %w[Include-Me] }

    it "excludes XML nodes under an exclude but including any includes within it" do
      xml = "<Root><Id>ID123</Id><Exclude><Assessment-Id>ID456</Assessment-Id><Include-Me>me!</Include-Me></Exclude></Root>"
      expected = {
        "id" => "ID123",
        "include_me" => "me!",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with preferred keys given" do
    let(:parser) { described_class.new preferred_keys: { "Internal-Name" => "external_name" } }

    it "uses a preferred key when given a node name that has one" do
      xml = "<Root><Id>ID123</Id><Internal-Name>blue</Internal-Name></Root>"
      expected = {
        "id" => "ID123",
        "external_name" => "blue",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with a list of nodes within a reasonable deep hierarchy" do
    let(:parser) { described_class.new }

    it "recognises a list and maps it into the data structure" do
      xml = "<Root><Subject><Sub-Subject><Rooms><Room><Id>ROOM1</Id><Name>Room 1</Name></Room><Room><Id>ROOM2</Id><Name>Room 2</Name></Room></Rooms></Sub-Subject></Subject></Root>"
      expected = {
        "subject" => {
          "sub_subject" => {
            "rooms" => [
              {
                "id" => "ROOM1",
                "name" => "Room 1",
              },
              {
                "id" => "ROOM2",
                "name" => "Room 2",
              },
            ],
          },
        },
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with node values containing numeric values" do
    let(:parser) { described_class.new }

    it "recognises values that can be numbers and maps them to floats or integers depending on decimal point" do
      xml = "<Root><Not-Quite-Numeric>123ABC</Not-Quite-Numeric><Floaty>13.45</Floaty><Inty>42</Inty></Root>"
      expected = {
        "not_quite_numeric" => "123ABC",
        "floaty" => 13.45,
        "inty" => 42,
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with nodes containing attributes" do
    let(:parser) { described_class.new }

    it "maps these nodes as a hash containing the node's attributes plus a value attribute with the value" do
      xml = '<Root><Money-Amount currency="GBP">139.99</Money-Amount></Root>'
      expected = {
        "money_amount" => {
          "currency" => "GBP",
          "value" => 139.99,
        },
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with list nodes specified" do
    let(:parser) { described_class.new list_nodes: ["Actually-A-List"] }

    it "treats given list node as a list, even if there is only one item in the list" do
      xml = "<Root><Implicit-List><Implicit-Item><Id>123</Id></Implicit-Item><Implicit-Item><Id>456</Id></Implicit-Item></Implicit-List><Actually-A-List><Actually-An-Item><Speech>I am in a list!</Speech></Actually-An-Item></Actually-A-List></Root>"
      expected = {
        "implicit_list" => [
          {
            "id" => 123,
          },
          {
            "id" => 456,
          },
        ],
        "actually_a_list" => [
          {
            "speech" => "I am in a list!",
          },
        ],
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with list nodes specified that are nested within other lists" do
    let(:parser) { described_class.new list_nodes: %w[Outer-List Inner-List] }

    it "can map nested lists" do
      xml = "<Root><Outer-List><Item><Inner-List><Item><Name>I am in a list!</Name></Item></Inner-List></Item></Outer-List></Root>"
      expected = {
        "outer_list" => [
          {
            "inner_list" => [
              {
                "name" => "I am in a list!",
              },
            ],
          },
        ],
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with namespaced nodes" do
    let(:parser) { described_class.new }

    it "ignores namespaces when mapping" do
      xml = "<Prefix:Root><Prefix:Id>123</Prefix:Id><Prefix:Name>name with a prefix</Prefix:Name></Prefix:Root>"
      expected = {
        "id" => 123,
        "name" => "name with a prefix",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with list nodes without roots" do
    let(:parser) { described_class.new rootless_list_nodes: { "Thing-Item" => "things" } }

    context "when list has more than one item" do
      it "constructs a list with a synthetic root in the new data structure" do
        xml = "<Root><Thing-Item><Name>thing 1</Name></Thing-Item><Thing-Item><Name>thing 2</Name></Thing-Item><Sibling>a sister!</Sibling></Root>"
        expected = {
          "things" => [
            {
              "name" => "thing 1",
            },
            {
              "name" => "thing 2",
            },
          ],
          "sibling" => "a sister!",
        }
        expect(parser.parse(xml)).to eq expected
      end
    end

    context "when list has only one item" do
      it "constructs a list with a synthetic root in the new data structure" do
        xml = "<Root><Thing-Item><Name>thing 1</Name></Thing-Item><Sibling>a sister!</Sibling></Root>"
        expected = {
          "things" => [
            {
              "name" => "thing 1",
            },
          ],
          "sibling" => "a sister!",
        }
        expect(parser.parse(xml)).to eq expected
      end
    end

    context "when specified node has node with same name elsewhere in document but we are targetting a node that has a particular parent node" do
      let(:parser) { described_class.new rootless_list_nodes: { "Our-Child" => { parents: %w[Our-Parent], key: "our_children" } } }

      it "constructs a list with a synthetic root in the data structure, only for the specified node" do
        xml = "<Root><Our-Parent><Our-Child><Name>Chris</Name></Our-Child></Our-Parent><Unconnected><Our-Child>Peter</Our-Child></Unconnected></Root>"
        expected = {
          "our_parent" => {
            "our_children" => [
              {
                "name" => "Chris",
              },
            ],
          },
          "unconnected" => {
            "our_child" => "Peter",
          },
        }
        expect(parser.parse(xml)).to eq expected
      end
    end
  end

  context "with more than one report type present in the xml" do
    let(:parser) { described_class.new(specified_report: { root_node: "Report", sub_node: "id", sub_node_value: "1" }) }

    it "parses the report with the specified id" do
      xml = "<Reports><Report><id>1</id><name>item one</name></Report><Report><id>2</id><name>item two</name></Report><Report><id>3</id><name>item three</name></Report></Reports>"
      expected = {
        "id" => 1,
        "name" => "item one",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with an excluded node containing multiple scalars" do
    let(:parser) { described_class.new(excludes: %w[id]) }

    it "does not add in random crap" do
      xml = "<Report><id><name>item one</name><name>item two</name><name>item three</name></id><boop>hello</boop></Report>"
      expected = {
        "boop" => "hello",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with CDATA blocks" do
    let(:parser) { described_class.new }

    it "reads the content of CDATA blocks and adds them to the data structure" do
      xml = "<Report><Data-Within-Cdata><![CDATA[hey i'm in a CDATA block]]></Data-Within-Cdata></Report>"
      expected = {
        "data_within_cdata" => "hey i'm in a CDATA block",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with the ID provided in a CDATA block" do
    let(:parser) { described_class.new(specified_report: { root_node: "Report", sub_node: "id", sub_node_value: "1" }) }

    it "parses the report with the specified id" do
      xml = "<Reports><Report><id><![CDATA[1]]></id><name>item one</name></Report><Report><id><![CDATA[2]]></id><name>item two</name></Report><Report><id><![CDATA[3]]></id><name>item three</name></Report></Reports>"
      expected = {
        "id" => 1,
        "name" => "item one",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with ignored attributes defined" do
    let(:parser) { described_class.new ignored_attributes: %w[ignored] }

    it "parses the report ignoring the ignored attributes" do
      xml = '<Root><Money currency="GBP">34.25</Money><Description ignored="ignored">i am the description</Description></Root>'
      expected = {
        "money" => {
          "currency" => "GBP",
          "value" => 34.25,
        },
        "description" => "i am the description",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end
end
