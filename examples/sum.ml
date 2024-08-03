open Stdlib.StdLabels
open Climate_std

let main =
  let%map_open.Command args = Arg.pos_all Param.int in
  print_endline (Printf.sprintf "%d" (List.fold_left args ~init:0 ~f:( + )))
;;

let () = Command.make main |> Command.run
