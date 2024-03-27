use std::env;
use semver::Version;

fn main() {
    let v1 = env::args().nth(1).expect("v1");
    let v2 = env::args().nth(2).expect("v2");
    let version1 = Version::parse(&v1).unwrap();
    let version2 = Version::parse(&v2).unwrap();

    if version1 > version2 {
        println!("{v1} is greater than {v2}");
    } else if version1 < version2 {
        println!("{v1} is less than {v2}");
    } else {
        println!("{v1} is equal to {v2}");
    }
}
