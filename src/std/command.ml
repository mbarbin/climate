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

type 'a t =
  | Group of
      { default_arg_parser : 'a Arg.t option
      ; desc : string option
      ; hidden : (string * 'a t) list
      ; commands : (string * 'a t) list
      ; mutable cached : 'a Climate.Command.t option
      }
  | Command of 'a Climate.Command.t
  | Singleton of
      { desc : string option
      ; arg_parser : 'a Climate.Arg_parser.t
      ; mutable cached : 'a Climate.Command.t option
      }

let rec to_command t =
  match t with
  | Command t -> t
  | Singleton ({ desc; arg_parser; cached } as r) ->
    (match cached with
     | Some command -> command
     | None ->
       let cached = Climate.Command.singleton ?desc arg_parser in
       r.cached <- Some cached;
       cached)
  | Group ({ default_arg_parser; desc; hidden; commands; cached } as r) ->
    (match cached with
     | Some command -> command
     | None ->
       let cached =
         Climate.Command.group
           ?default_arg_parser
           ?desc
           (List.concat
              [ hidden
                |> List.map (fun (name, t) ->
                  Climate.Command.subcommand ~hidden:true name (to_command t))
              ; commands
                |> List.map (fun (name, t) ->
                  Climate.Command.subcommand ~hidden:false name (to_command t))
              ])
       in
       r.cached <- Some cached;
       cached)
;;

let make ?desc arg_parser =
  let t = Singleton { desc; arg_parser; cached = None } in
  ignore (to_command t : _ Climate.Command.t);
  t
;;

let group ?default_arg_parser ?desc ?(hidden = []) commands =
  let t = Group { default_arg_parser; desc; hidden; commands; cached = None } in
  ignore (to_command t : _ Climate.Command.t);
  t
;;

let print_completion_script_bash = Command Climate.Command.print_completion_script_bash

let completion_script_bash
  ?eval_config
  ?program_exe_for_reentrant_query
  ?global_symbol_prefix
  ?command_hash_in_function_names
  t
  ~program_name
  =
  Climate.Command.completion_script_bash
    ?eval_config
    ?program_exe_for_reentrant_query
    ?global_symbol_prefix
    ?command_hash_in_function_names
    (to_command t)
    ~program_name
;;

let eval ?eval_config t raw = Climate.Command.eval ?eval_config (to_command t) raw
let run ?eval_config t = Climate.Command.run ?eval_config (to_command t)

module Std = struct
  open Climate.Arg_parser

  let ( let+ ) = ( let+ )
  let ( and+ ) = ( and+ )

  module Arg = Arg
  module Param = Param
end
