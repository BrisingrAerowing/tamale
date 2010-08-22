require "tamale"
require "lunatest"

local V = tamale.var

local M

function setup(x)
   M = tamale.matcher {
      { 27, "twenty-seven" },
      { "str", "string" },
      { { 1, 2, 3},
        function(t) return "one two three" end },
      { { 1, {2, "three"}, 4}, function(t) return "success" end },
      { { "gt3", V"X"}, function(t) return 10 * t.X end,
        where=function (t) return t.X > 3 end },
      { { V"a", V"b", V"c", V"b" }, function(t) return "ABCB" end },
      { { "a", {"b", V"X" }, "c", V"X"},
        function(t) return "X is " .. t.X end },
      { { "extract", { V"_", V"_", V"third", V"_" } },
        function(t) return t.third end },
   }
end


function test_m()
   assert_true(M)
end

function test_literal_num()
   assert_equal("twenty-seven", M(27))
end

function test_literal_str()
   assert_equal("string", M "str")
end

function test_literal_num_trio()
   assert_equal("one two three", M {1, 2, 3})
end

function test_literal_num_trio_too_many()
   assert_false(M {1, 2, 3, 4})
end

function test_nomatch()
   assert_false(M {1, 2, 4})
end

function test_matchvar()
   assert_equal(70, M {"gt3", 7})
end

function test_matchvar_fail()
   assert_false(M {"gt3", "boo"})
end

function test_matchvar_nested()
   assert_equal("success", (M {1, {2, "three"}, 4}))
end

function test_match_repeated_num_var()
   assert_equal("ABCB", M {1, 2, 3, 2})
end

function test_match_repeated_str_var()
   assert_equal("ABCB", M {"apple", "banana", "corn", "banana"})
end

function test_match_repeated_table_var()
   local apple, banana, corn = {}, {}, {}
   assert_equal("ABCB", M {apple, banana, corn, banana})
end

function test_match_repeated_table_var_FAIL_out_of_order()
   local apple, banana, corn = {}, {}, {}
   assert_false(M {apple, corn, banana, banana})
end

function test_destructuring()
   assert_equal("X is FOO", M { "a", { "b", "FOO" }, "c", "FOO"})
end

function test_dont_care()
   assert_equal("third",
                M { "extract",
                  { "first", "second", "third", "fourth" }})
end

function test_match_any()
   local m = tamale.matcher { { V"_", function(t) return t end } }
   assert_true(m "any string")
   assert_true(m(4))
   assert_true(m {"x", "y", "z"})
end


--Match against three values that add up to 35, and use
--structural matching to check that the first and third are the same.
local aba_pt_match = tamale.matcher {
      { { x=V"X", y=V"Y", z=V"X" },
        function(t) return t.X + t.Y + t.X end }
   }

function test_kv_match()
   assert_equal(35, aba_pt_match {x=15, y=5, z=15 })
end

function test_kv_match_fail()
   assert_false(aba_pt_match {x=10, y=20, z=5 })
end


--Empty tables can also be used as sentinel values, so make it
--possibly to force comparison by identity rather than structure.
function test_match_IDs()
   local a, b, c = {}, {}, {}

   local m = tamale.matcher {
      { {a, b, c}, "PASS" },
      ids={a, b, c}
   }
   assert_equal("PASS", m {a, b, c})
   -- (b and c are equal by structure but not identity)
   assert_false(m {a, c, b})
end


lunatest.run()
