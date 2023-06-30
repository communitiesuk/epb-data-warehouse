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

  context "with node values containing money ranges" do
    let(:parser) { described_class.new }

    it "recognises values that can be money ranges and leaves them in place" do
      xml = "<Root><Cost-Range>&#xA3;80 - &#xA3;120</Cost-Range></Root>"
      expected = {
        "cost_range" => "£80 - £120",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with node values containing strings with XML escapes" do
    let(:parser) { described_class.new }

    it "recognises values with XML escapes and just unescapes them" do
      xml = "<Root><Escaped>esc&#x61;ped</Escaped></Root>"
      expected = {
        "escaped" => "escaped",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with node values containing strings including a slash character and a superscript character" do
    let(:parser) { described_class.new }

    it "writes the entire string into the output hash" do
      xml = "<Root><Description>Average thermal transmittance 0.28 W/m²K</Description></Root>"
      expected = {
        "description" => "Average thermal transmittance 0.28 W/m²K",
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with node values containing strings with an escaped ampersand" do
    let(:parser) { described_class.new }

    it "writes the string correctly with no dropped spaces" do
      xml = "<Root><Entertainers>Laurel &amp; Hardy</Entertainers></Root>"
      expected = {
        "entertainers" => "Laurel & Hardy",
      }
      expect((parser.parse xml)).to eq expected
    end
  end

  context "with node values containing strings which exceed the character limit" do
    let(:parser) { described_class.new }

    it "writes the string correctly with no dropped spaces" do
      xml = "<Root><Location-Description>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetu</Location-Description></Root>"
      expected = {
        "location_description" => "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi...",
      }
      expect((parser.parse xml)).to eq expected
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

  context "with nodes specified that will ignore all attributes" do
    let(:parser) { described_class.new nodes_ignoring_attributes: %w[Ignore-My-Attributes] }

    it "parses the report ignoring all attributes on the specified nodes but leaving others" do
      xml = '<Root><Ignore-My-Attributes quantity="metres">23</Ignore-My-Attributes><Length quantity="cm">5</Length></Root>'
      expected = {
        "ignore_my_attributes" => 23,
        "length" => {
          "quantity" => "cm",
          "value" => 5,
        },
      }
      expect(parser.parse(xml)).to eq expected
    end
  end

  context "with nodes specified that will ignore all attributes ignoring node namespace" do
    let(:parser) { described_class.new nodes_ignoring_attributes: %w[Ignore-My-Attributes] }

    it "parses the report ignoring all attributes on the specified nodes but leaving others" do
      xml = '<Root><SAP:Ignore-My-Attributes quantity="metres">23</SAP:Ignore-My-Attributes><SAP:Length quantity="cm">5</SAP:Length></Root>'
      expected = {
        "ignore_my_attributes" => 23,
        "length" => {
          "quantity" => "cm",
          "value" => 5,
        },
      }
      expect(parser.parse(xml)).to eq expected
    end
  end
end
