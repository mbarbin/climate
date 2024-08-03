(* This program ignores its arguments and prints out a bash script.
   Put the script in a file and source it in your shell. You will find
   that the command "fib" now autocompletes to the Fibonacci sequence,
   adding a new number every time you press tab.

   dune exec examples/fib.exe > /tmp/completion.sh
   . /tmp/completion.sh
   fib <TAB> <TAB> <TAB> <TAB> ...
*)
open Climate_std

let () =
  let command =
    Command.singleton
      (let%map_open.Command argv0 = Arg.argv0
       and _ =
         Arg.pos_all
           Param.int
           ~completion:
             (Arg.Completion.reentrant_parse
                (let%map.Command all = Arg.pos_all Param.int in
                 let x =
                   match List.rev all with
                   | [] -> 1
                   | [ a ] -> a
                   | a :: b :: _ -> a + b
                 in
                 [ x ]))
       in
       argv0)
  in
  let program_exe_for_reentrant_query = `Other (Command.run command) in
  print_endline
    (Command.completion_script_bash
       command
       ~program_name:"fib"
       ~program_exe_for_reentrant_query
       ~global_symbol_prefix:(`Custom "__fib__"))
;;
