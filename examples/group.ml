let term name =
  let open Command in
  let+ x = Arg.named_req [ "x" ] Param.string
  and+ y = Arg.named_req [ "y" ] Param.string in
  print_endline (Printf.sprintf "%s %s %s" name x y)
;;

let () =
  let open Command in
  group
    [ "foo", make (term "foo")
    ; "bar", group ~default_arg_parser:(term "bar") [ "baz", make (term "baz") ]
    ]
  |> run
;;
