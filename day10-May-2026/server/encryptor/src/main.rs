use std::env;
use sha2::{Sha256, Digest};
use std::time::Instant;

fn main() {
    // Get the input string and "difficulty" from command line arguments
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        eprintln!("Usage: encryptor <text> <iterations>");
        std::process::exit(1);
    }

    let text = &args[1];
    let iterations: u32 = args[2].parse().unwrap_or(1000);

    println!("Rust: Starting heavy computation on '{}' for {} iterations...", text, iterations);
    
    let start = Instant::now();
    let mut current_hash = text.clone();

    // Perform heavy hashing
    for _ in 0..iterations {
        let mut hasher = Sha256::new();
        hasher.update(current_hash.as_bytes());
        let result = hasher.finalize();
        current_hash = format!("{:x}", result);
    }

    let duration = start.elapsed();
    
    println!("Final Hash: {}", current_hash);
    println!("Time taken: {:?}", duration);
}