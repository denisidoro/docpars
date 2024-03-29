use docopt::Docopt;
use docopt::Value::{self, Counted, List, Plain, Switch};
use std::error::Error;

fn key_string(x: &str) -> &str {
    if let Some(prefixed) = x.strip_prefix("--") {
        prefixed
    } else if x.starts_with('<') {
        let l = x.len();
        &x[1..(l - 1)]
    } else {
        x
    }
}

fn escape_quote(x: &str) -> String {
    x.replace('\'', "'\\''")
}

fn value_string(x: &Value) -> String {
    match x {
        Switch(b) => format!("{}", b),
        Counted(n) => format!("'{}'", n),
        Plain(o) => match o {
            Some(y) => format!("'{}'", escape_quote(y)),
            None => "".to_owned(),
        },
        List(v) => {
            let mut s = String::from("(");
            let quoted_values: Vec<String> =
                v.iter().map(|y| format!("'{}'", escape_quote(y))).collect();
            s.push_str(&quoted_values.join(" "));
            s.push(')');
            s
        }
    }
}

enum Data<'a> {
    Unknown,
    Help(String),
    Parse(String, &'a [String]),
}

fn get_data(argv: &[String]) -> Result<Data, Box<dyn Error>> {
    match argv.get(0).as_ref().map(|s| s.as_str()) {
        Some("--help") | Some("-h") => {}
        _ => return Ok(Data::Unknown),
    }
    let help_msg = match argv.get(1) {
        Some(msg) => msg.to_owned(),
        _ => return Ok(Data::Unknown),
    };
    match argv.get(2).as_ref().map(|s| s.as_str()) {
        Some(":") => {}
        _ => return Ok(Data::Unknown),
    }
    match argv.get(3).as_ref().map(|s| s.as_str()) {
        Some("--help") | Some("-h") => Ok(Data::Help(help_msg)),
        _ => Ok(Data::Parse(help_msg, &argv[2..])),
    }
}

pub fn gen_eval_string(argv: &[String]) -> Result<(), Box<dyn Error>> {
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
                    } else {
                    }
                    e.exit();
                });

            for (k, v) in parsed_args.map.iter() {
                println!("{}={}", key_string(k).replace('-', "_"), value_string(v));
            }
        }
        _ => {
            println!("Usage: docpars -h <docopt> : <args>...");
        }
    }
    Ok(())
}
