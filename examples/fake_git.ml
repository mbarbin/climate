(* Git-like program to exercise completion *)
open Climate_std

let branch_param =
  { Command.Param.string with
    default_value_name = "BRANCH"
  ; completion =
      Some
        (Command.Arg.Completion.reentrant_parse
           ((* This is supposed to simulate passing an alternative
               root directory to git, and having it be respected when
               invoking git while generating completion suggestions. *)
            let%map_open.Command _root = Arg.named_opt [ "root" ] Param.file in
            [ "main"; "devel" ]))
  }
;;

let checkout =
  (* Multiple different completions for positional arguments *)
  let%map_open.Command _branch = Arg.pos_req 0 (Param.string_enum [ "foo"; "bar" ])
  and _ = Arg.pos_req 1 Param.file
  and _ = Arg.pos_right 2 branch_param in
  ()
;;

let _checkout2 =
  (* If you prefer (let+) syntax you can use it as well. *)
  let open Command in
  (* Multiple different completions for positional arguments *)
  let+ _branch = Arg.pos_req 0 (Param.string_enum [ "foo"; "bar" ])
  and+ _ = Arg.pos_req 1 Param.file
  and+ _ = Arg.pos_right 2 branch_param in
  ()
;;

let commit =
  let%map_open.Command _amend = Arg.flag [ "amend"; "a" ]
  and _branch = Arg.named_opt [ "b"; "branch" ] branch_param
  and _message = Arg.named_opt [ "m"; "message" ] Param.string in
  ()
;;

let log =
  let%map_open.Command _pretty =
    Arg.named_opt
      [ "pretty"; "p" ]
      (Param.string_enum [ "full"; "fuller"; "short"; "oneline" ])
  in
  ()
;;

let bisect_common =
  (* Mixing subcommands and positional arguments *)
  let%map_open.Command _foo = Arg.named_opt [ "foo" ] Param.int
  and _bar = Arg.flag [ "bar" ]
  and _baz = Arg.pos_opt 0 (Param.string_enum [ "x"; "y"; "z" ]) in
  ()
;;

let () =
  let open Command in
  group
    ~desc:"Fake version control"
    [ "config", singleton Arg.unit
    ; "checkout", singleton checkout
    ; "commit", singleton commit
    ; "log", singleton log
    ; ( "bisect"
      , group
          ~default_arg_parser:bisect_common
          ~desc:"Binary search through previous commits."
          [ "start", singleton bisect_common ~desc:"Start a bisect."
          ; "reset", singleton bisect_common ~desc:"Stop a bisect."
          ] )
    ]
    ~hidden:[ "__internal", print_completion_script_bash ]
  |> run
;;
