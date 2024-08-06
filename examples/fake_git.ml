(* Git-like program to exercise completion *)

let branch_param =
  let open Command.Std in
  { Param.string with
    default_value_name = "BRANCH"
  ; completion =
      Some
        (Arg.Completion.reentrant_parse
           ((* This is supposed to simulate passing an alternative
               root directory to git, and having it be respected when
               invoking git while generating completion suggestions. *)
            let+ _root = Arg.named_opt [ "root" ] Param.file in
            [ "main"; "devel" ]))
  }
;;

let checkout =
  let open Command.Std in
  (* Multiple different completions for positional arguments *)
  let+ _branch = Arg.pos_req 0 (Param.string_enum [ "foo"; "bar" ])
  and+ _ = Arg.pos_req 1 Param.file
  and+ _ = Arg.pos_right 2 branch_param in
  ()
;;

let commit =
  let open Command.Std in
  let+ _amend = Arg.flag [ "amend"; "a" ]
  and+ _branch = Arg.named_opt [ "b"; "branch" ] branch_param
  and+ _message = Arg.named_opt [ "m"; "message" ] Param.string in
  ()
;;

let log =
  let open Command.Std in
  let+ _pretty =
    Arg.named_opt
      [ "pretty"; "p" ]
      (Param.string_enum [ "full"; "fuller"; "short"; "oneline" ])
  in
  ()
;;

let bisect_common =
  let open Command.Std in
  (* Mixing subcommands and positional arguments *)
  let+ _foo = Arg.named_opt [ "foo" ] Param.int
  and+ _bar = Arg.flag [ "bar" ]
  and+ _baz = Arg.pos_opt 0 (Param.string_enum [ "x"; "y"; "z" ]) in
  ()
;;

let () =
  let open Command in
  group
    ~desc:"Fake version control"
    [ "config", make Arg.unit
    ; "checkout", make checkout
    ; "commit", make commit
    ; "log", make log
    ; ( "bisect"
      , group
          ~default_arg_parser:bisect_common
          ~desc:"Binary search through previous commits."
          [ "start", make bisect_common ~desc:"Start a bisect."
          ; "reset", make bisect_common ~desc:"Stop a bisect."
          ] )
    ]
    ~hidden:[ "__internal", print_completion_script_bash ]
  |> run
;;
