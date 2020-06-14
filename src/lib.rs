use docopt::Docopt;
use docopt::Value::{self, Counted, List, Plain, Switch};
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

enum Data<'a> {
    Unknown,
    Help(String),
    Parse(String, &'a [String]),
}

fn get_data(argv: &Vec<String>) -> Result<Data, Box<dyn Error>> {
    match argv.get(0).as_ref().map(|s| s.as_str()) {
        Some("--help") | Some("-h") => {}
        _ => return Ok(Data::Unknown),
    }
    let help_msg: String;
    match argv.get(1) {
        Some(msg) => help_msg = msg.to_owned(),
        _ => return Ok(Data::Unknown),
    }
    match argv.get(2).as_ref().map(|s| s.as_str()) {
        Some(":") => {}
        _ => return Ok(Data::Unknown),
    }
    match argv.get(3).as_ref().map(|s| s.as_str()) {
        Some("--help") | Some("-h") => Ok(Data::Help(help_msg)),
        _ => return Ok(Data::Parse(help_msg, &argv[2..])),
    }
}

pub fn gen_eval_string(argv: &Vec<String>) -> Result<(), Box<dyn Error>> {
    let data = get_data(argv)?;

    match data {
        Data::Help(msg) => {
            println!(
                r#"cat << DOCPARSEOF
{}
DOCPARSEOF
                exit 0"#,
                msg
            );
        }
        Data::Parse(msg, args) => {
            let parsed_args = Docopt::new(msg)
                .and_then(|d| d.argv(args).parse())
                .unwrap_or_else(|e| {
                    if e.fatal() {
                        println!("exit 1");
                        e.exit();
                    } else {
                        e.exit();
                    }
                });

            for (k, v) in parsed_args.map.iter() {
                println!("{}={}", key_string(k).replace("-", "_"), value_string(v));
            }
        }
        _ => {
            println!("Usage: docpars -h <docopt> : <args>...");
        }
    }
    Ok(())
}
