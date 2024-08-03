open Climate_std

let main =
  let%map_open.Command a = Arg.pos_req 0 Param.int
  and b = Arg.pos_req 1 Param.int in
  print_endline (Printf.sprintf "%d" (a + b))
;;

let () = Command.make main |> Command.run
