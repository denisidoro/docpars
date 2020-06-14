extern crate docpars;
use std::env;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    let argv: Vec<String> = env::args().skip(1).collect();
    docpars::gen_eval_string(&argv)?;
    Ok(())
}
