type 'a parse = string -> ('a, [ `Msg of string ]) result
type 'a print = Format.formatter -> 'a -> unit
type 'a completion = 'a Climate.Arg_parser.Completion.t

module Param = struct
  type 'a t = 'a Climate.Arg_parser.conv =
    { parse : 'a parse
    ; print : 'a print
    ; default_value_name : string
    ; completion : 'a completion option
    }

  include struct
    open Climate.Arg_parser

    let string = string
    let int = int
    let float = float
    let bool = bool
    let file = file
    let enum = enum
    let string_enum = string_enum
  end
end

module Arg = struct
  include Climate.Arg_parser
end

include Climate.Command

module type Infix_operators_sig = sig
  type 'a t

  val ( $ ) : ('a -> 'b) t -> 'a t -> 'b t
  val ( <*> ) : ('a -> 'b) t -> 'a t -> 'b t
  val ( <* ) : 'a t -> unit t -> 'a t
  val ( *> ) : unit t -> 'a t -> 'a t
  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
end

module Infix_operators = struct
  open Arg

  let ( $ ) = apply
  let ( <*> ) = apply
  let ( <* ) a do_b = map (both a do_b) ~f:(fun (a, ()) -> a)
  let ( *> ) do_a b = map (both do_a b) ~f:(fun ((), b) -> b)
  let ( >>| ) = ( >>| )
end

include struct
  open Climate.Arg_parser

  let ( let+ ) = ( let+ )
  let ( and+ ) = ( and+ )
end

module Let_syntax = struct
  include Infix_operators

  module Let_syntax = struct
    include struct
      open Climate.Arg_parser

      let map = map
      let both = both
    end

    module Open_on_rhs = struct
      include Infix_operators
      module Param = Param
      module Arg = Arg
    end
  end
end
