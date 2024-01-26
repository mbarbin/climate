open Climate

let eval_and_print_parse_error (command : 'a Command.t) command_line =
  try
    let _ : 'a = Command.eval command command_line in
    ()
  with
  | Parse_error.E error -> print_endline (Parse_error.to_string error)
;;

let check_and_print_spec_error (make_parser : unit -> 'a Arg_parser.t) =
  try
    let _ : 'a Command.t = Command.singleton (make_parser ()) in
    ()
  with
  | Spec_error.E error -> print_endline (Spec_error.to_string error)
;;
