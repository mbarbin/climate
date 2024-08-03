open Climate_std

let term name =
  let%map_open.Command x = Arg.named_req [ "x" ] Param.string
  and y = Arg.named_req [ "y" ] Param.string in
  print_endline (Printf.sprintf "%s %s %s" name x y)
;;

let () =
  let open Command in
  group
    [ subcommand "foo" (singleton (term "foo"))
    ; subcommand
        "bar"
        (group
           ~default_arg_parser:(term "bar")
           [ subcommand "baz" (singleton (term "baz")) ])
    ]
  |> run
;;
