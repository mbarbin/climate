open Climate

module Color = struct
  type t =
    | Red
    | Green
    | Blue

  (* Tell climate how to handle colours *)
  let conv =
    let open Arg_parser in
    enum ~default_value_name:"COLOR" [ "red", Red; "green", Green; "blue", Blue ]
  ;;
end

(* Ansi escape sequence to reset the termminal style *)
let ansi_reset = "\x1b[0m"

(* Returns the escape sequence to set the terminal style *)
let ansi_style ~bold ~underline ~color =
  let effects =
    List.append (if bold then [ ";1" ] else []) (if underline then [ ";4" ] else [])
  in
  let color_code =
    match (color : Color.t option) with
    | None -> 0
    | Some Red -> 31
    | Some Green -> 32
    | Some Blue -> 34
  in
  Printf.sprintf "\x1b[%d%sm" color_code (String.concat "" effects)
;;

(* Print the words in the given style *)
let main ~bold ~underline ~color words =
  print_string (ansi_style ~bold ~underline ~color);
  print_string (String.concat " " words);
  print_string ansi_reset;
  print_newline ()
;;

let () =
  let command =
    Command.singleton ~desc:"Echo with style!"
    @@
    let open Arg_parser in
    (* Describe and parse the command line arguments:*)
    let+ bold = flag [ "bold" ] ~desc:"Make the text bold"
    and+ underline = flag [ "underline" ] ~desc:"Underline the text"
    and+ color = named_opt [ "color" ] Color.conv ~desc:"Set the text color"
    and+ words = pos_all string
    and+ completion =
      flag [ "completion" ] ~desc:"Print this program's completion script and exit"
    in
    if completion
    then `Completion
    else `Main (fun () -> main ~bold ~underline ~color words)
  in
  (* Run the parser yielding either a main function to call or an indication
     that we should print the completion script. *)
  match Command.run command with
  | `Completion -> print_endline (Command.completion_script_bash command)
  | `Main main -> main ()
;;
