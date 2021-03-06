require "test_helper"

module Csscss::Parser
  describe Common do
    class CommonTest
      include Common
    end

    before { @parser = CommonTest.new }

    describe "#stri" do
      it "parses case insensitive strings" do
        @parser.stri("a").must_parse "a"
        @parser.stri("A").must_parse "a"
        @parser.stri("A").wont_parse "b"

        @parser.stri("This too shall pass").must_parse "this TOO shall PASS"
        @parser.stri("[").must_parse "["
      end
    end

    describe "#spaces" do
      it "parses series of spaces" do
        @parser.space.must_parse " "
        @parser.space.must_parse "  "
        @parser.space.must_parse "\n"
        @parser.space.wont_parse "  a"

        @parser.space.wont_parse ""
        @parser.space?.must_parse ""
      end
    end

    describe "#symbol" do
      it "parses case insensitive characters followed by spaces" do
        @parser.symbol("foo").must_parse "foo"
        @parser.symbol("foo").must_parse "foo  "
        @parser.symbol("foo").must_parse "Foo  "
        @parser.symbol("foo").wont_parse " Foo  "
      end

      it "optionally captures input" do
        parsed = @parser.symbol("foo", :foo).parse("Foo  ")
        parsed[:foo].must_equal "Foo"
      end
    end

    describe "between and helpers" do
      it "parses characters surrounded" do
        @parser.between("[", "]") { @parser.symbol("foo") }.must_parse "[foo]"
      end

      it "parses input surrounded by parens" do
        @parser.parens { @parser.symbol("foo") }.must_parse "(foo)"
        @parser.parens { @parser.symbol("foo") }.must_parse "(FOo)  "
        @parser.parens { @parser.symbol("foo") }.must_parse "(FOo  )  "
        @parser.parens { @parser.symbol("food") }.wont_parse "(FOo"
      end

      it "parses input surrounded by double quotes" do
        @parser.double_quoted { @parser.symbol("foo") }.must_parse %("foo")
        @parser.double_quoted { @parser.symbol("foo") }.must_parse %("FOo  ")
        @parser.double_quoted { @parser.symbol("foo") }.must_parse %("FOo  "  )
        @parser.double_quoted { @parser.symbol("food") }.wont_parse %("FOo)
      end

      it "parses input surrounded by single quotes" do
        @parser.single_quoted { @parser.symbol('foo') }.must_parse %('foo')
        @parser.single_quoted { @parser.symbol('foo') }.must_parse %('FOo  ')
        @parser.single_quoted { @parser.symbol('foo') }.must_parse %('FOo  '  )
        @parser.single_quoted { @parser.symbol('food') }.wont_parse %('FOo)
      end
    end

    describe "number and numbers" do
      it "parses single numbers" do
        @parser.number.must_parse "1"
        @parser.number.wont_parse "12"
        @parser.number.wont_parse "a"
        @parser.number.wont_parse "1 "
      end

      it "parses multiple numbers" do
        @parser.numbers.must_parse "1"
        @parser.numbers.must_parse "12"
        @parser.numbers.wont_parse "12 "
        @parser.numbers.wont_parse "1223a"
      end

      it "parses decimals" do
        @parser.decimal.must_parse "1"
        @parser.decimal.must_parse "12"
        @parser.decimal.must_parse "12."
        @parser.decimal.must_parse "12.0123"
        @parser.decimal.wont_parse "1223a"
      end

      it "parses percentages" do
        @parser.percent.must_parse "100%"
        @parser.percent.must_parse "100% "
        @parser.percent.must_parse "100.344%"
        @parser.percent.wont_parse "100 %"
      end

      it "parses lengths" do
        @parser.length.must_parse "123px"
        @parser.length.must_parse "123EM"
        @parser.length.must_parse "1.23Pt"
      end
    end

    describe "url" do
      it "parses http" do
        @parser.http.must_parse "foo.jpg"
        @parser.http.must_parse 'foo\(bar\).jpg'
        @parser.http.must_parse 'http://foo\(bar\).jpg'
        @parser.http.must_parse 'http://foo.com/baz/\(bar\).jpg'
      end

      it "parses urls" do
        @parser.url.must_parse "url(foo.jpg)"
        @parser.url.must_parse "url(  foo.jpg  )"
        @parser.url.must_parse 'url("foo.jpg")'
        @parser.url.must_parse "url('foo.jpg')"
        @parser.url.must_parse "url('foo.jpg'  )"
        @parser.url.must_parse 'url(foo\(bar\).jpg)'
      end
    end
  end
end
