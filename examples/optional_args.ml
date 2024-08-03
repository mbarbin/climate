open Climate_std

let term =
  let%map_open.Command x = Arg.named_with_default [ "x" ] Param.string ~default:"foo"
  and y = Arg.named_with_default [ "y" ] Param.string ~default:"bar" in
  Printf.printf "%s and %s" x y
;;

let () = Command.make term |> Command.run
