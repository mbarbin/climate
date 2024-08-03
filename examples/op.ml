open Stdlib.StdLabels
open Climate_std

let main =
  let%map_open.Command op = Arg.pos_req 0 Param.string
  and args = Arg.pos_right 1 Param.int in
  let init, op =
    match op with
    | "+" -> 0, ( + )
    | "*" -> 1, ( * )
    | other -> failwith (Printf.sprintf "unknown op %s" other)
  in
  print_endline (Printf.sprintf "%d" (List.fold_left args ~init ~f:op))
;;

let () = Command.make main |> Command.run
