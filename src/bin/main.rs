extern crate docpars;
use std::env;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    let mut args = env::args();
    docpars::gen_eval_string(&mut args)?;
    Ok(())
}
