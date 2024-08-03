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
