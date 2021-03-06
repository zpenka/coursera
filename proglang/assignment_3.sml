(* Second programming assignment for Programming Languages Coursera course *)

(* Given Data: *)
exception NoAnswer

(* 1 *)
val only_capitals =
	List.filter (fn str => Char.isUpper(String.sub(str, 0)))

(* 2 *)
val longest_string1 =
	List.foldl (fn (a, b) => if String.size a > String.size b then a else b) ""

(* 3 *)
val longest_string2 =
	List.foldl (fn (a, b) => if String.size a >= String.size b then a else b) ""

(* 4 *)
fun longest_string_helper f =
	List.foldl (fn (a, b) => if f (String.size a, String.size b) then a else b) ""

val longest_string3 =
	longest_string_helper (fn (a, b) => a > b)

val longest_string4 =
	longest_string_helper (fn (a, b) => a >= b)

(* 5 *)
val longest_capitalized = longest_string1 o only_capitals

(* 6 *)
val rev_string = String.implode o List.rev o String.explode

(* 7 *)
fun first_answer f [] = raise NoAnswer
	| first_answer f (x::xs) = 
		case f x of
			  NONE => first_answer f xs
			| SOME v => v

(* 8 *)
fun all_answers f xs =
	let
		fun iterate ([], acc) = SOME []
			| iterate (x::xs, acc) =
				case f x of
					  NONE => NONE
					| SOME v => iterate (xs, v @ acc)
	in
		iterate(xs, [])
	end

(* Given Datatypes and Function for problems 9-12: *)
datatype pattern = Wildcard
		 | Variable of string
		 | UnitP
		 | ConstP of int
		 | TupleP of pattern list
		 | ConstructorP of string * pattern

datatype valu = Const of int
	      | Unit
	      | Tuple of valu list
	      | Constructor of string * valu

fun g f1 f2 p =
    let 
	val r = g f1 f2 
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end

(* 9 *)
val count_wildcards = g (fn _ => 1) (fn _ => 0)
val count_wild_and_variable_lengths = g (fn _ => 1) String.size
fun count_some_var (a, b) = g (fn _ => 0) (fn x => if x = a then 1 else 0) b

(* 10 *)
fun check_pat pattern =
  let
    fun list_vars (Variable x) = [x]
      | list_vars (TupleP ps) = List.concat (map list_vars ps)
      | list_vars (_) = [ ]
    fun different ([]) = true
      | different (x::xs) =
          not (List.exists (fn y => x = y) xs) andalso different xs
  in
    (different o list_vars) pattern
  end

(* 11 *)
fun match (_, Wildcard) = SOME []
  | match (v, Variable s) = SOME [(s, v)]
  | match (Unit, UnitP) = SOME []
  | match (Const a, ConstP b) = if a =b then SOME [] else NONE
  | match (Tuple ps, TupleP qs) =
      if length ps = length qs then
        all_answers match (ListPair.zip(ps, qs))
      else
        NONE
  | match (Constructor (s,v), ConstructorP (t, w)) =
      if s = t then
        match (v, w)
      else
        NONE
  | match _ = NONE

(* 12 *)
fun first_match v ps =
  SOME (first_answer (fn x => match (v, x)) ps) handle NoAnswer => NONE