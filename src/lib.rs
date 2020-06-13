use docopt::Docopt;
use docopt::Value::{self, Counted, List, Plain, Switch};
use std::env;
use std::error::Error;

fn key_string(x: &str) -> &str {
    if x.starts_with("--") {
        &x[2..]
    } else if x.starts_with('<') {
        let l = x.len();
        &x[1..(l - 1)]
    } else {
        x
    }
}

fn value_string(x: &Value) -> String {
    match x {
        Switch(b) => format!("{}", b),
        Counted(n) => format!("'{}'", n),
        Plain(o) => match o {
            Some(y) => format!("'{}'", y),
            None => "".to_owned(),
        },
        List(v) => {
            let mut s = String::from("(");
            let quoted_values: Vec<String> = v.iter().map(|y| format!("'{}'", y)).collect();
            s.push_str(&quoted_values.join(" "));
            s.push_str(")");
            s
        }
    }
}

pub fn gen_eval_string(args: &mut env::Args) -> Result<(), Box<dyn Error>> {
    // get help message
    let error_message = "Usage: docpars -h <docopt> : <args>...";
    args.next().ok_or(error_message)?;
    args.next().ok_or(error_message)?;
    let help_message = args.next().ok_or(error_message)?;
    args.next().ok_or(error_message)?;

    // handle --help
    let mut first_arg: Option<String> = None;
    if let Some(x) = args.next() {
        first_arg = Some(x.clone());
        match x.as_str() {
            "--help" | "-h" => {
                println!(
                    r#"cat << DOCPARSEOF
{}
DOCPARSEOF
                exit 0"#,
                    help_message
                );
                return Ok(());
            }
            _ => {}
        }
    }
    let semicolon = String::from(":");
    let v = match first_arg {
        Some(x) => vec![semicolon, x],
        None => vec![semicolon],
    };
    let args = v.into_iter().chain(args);

    // parse argv and exit the program with an error message if it fails
    let parsed_args = Docopt::new(help_message)
        .and_then(|d| d.argv(args).parse())
        .unwrap_or_else(|e| e.exit());

    for (k, v) in parsed_args.map.iter() {
        println!("{}={}", key_string(k), value_string(v));
    }

    Ok(())
}
