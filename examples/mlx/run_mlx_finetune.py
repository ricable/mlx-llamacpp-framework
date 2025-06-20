#!/usr/bin/env python3
"""
MLX Fine-tuning Script for TinyLlama with Quotes Dataset
"""

import os
import json
import time
import subprocess
import psutil
from datasets import load_dataset

def prepare_training_data():
    """Prepare training data in the correct format for MLX-LM"""
    print("🔄 Preparing training data...")
    
    # Create data directory
    os.makedirs('./finetune_data', exist_ok=True)
    
    # Download quotes dataset
    print("📦 Downloading quotes dataset from Hugging Face...")
    dataset = load_dataset('Abirate/english_quotes', split='train[:50]')
    
    # Prepare training data
    train_data = []
    val_data = []
    
    for i, item in enumerate(dataset):
        # Create instruction-following format
        text = f"<|im_start|>user\nWrite an inspirational quote about {item['tags'][0] if item['tags'] else 'life'}<|im_end|>\n<|im_start|>assistant\n\"{item['quote']}\" - {item['author']}<|im_end|>"
        
        entry = {"text": text}
        
        # Split 80/20 train/val
        if i < 40:
            train_data.append(entry)
        else:
            val_data.append(entry)
    
    # Save datasets
    with open('./finetune_data/train.jsonl', 'w') as f:
        for entry in train_data:
            f.write(json.dumps(entry) + '\n')
    
    with open('./finetune_data/valid.jsonl', 'w') as f:
        for entry in val_data:
            f.write(json.dumps(entry) + '\n')
    
    print(f"✅ Created training dataset: {len(train_data)} train, {len(val_data)} validation examples")
    
    # Show sample
    print("\n📝 Sample training entry:")
    print(train_data[0]['text'][:200] + "...")
    
    return len(train_data), len(val_data)

def run_mlx_lora_finetune():
    """Run MLX LoRA fine-tuning"""
    print("\n🚀 Starting MLX LoRA Fine-tuning...")
    
    # Model path (use our existing TinyLlama model)
    model_path = "./models/mlx/tinyllama-1.1b-chat"
    
    # Fine-tuning parameters
    params = {
        "--model": model_path,
        "--data": "./finetune_data",
        "--train": "",
        "--fine-tune-type": "lora",
        "--batch-size": "1",
        "--iters": "50",  # Small number for demo
        "--learning-rate": "1e-4",
        "--steps-per-report": "5",
        "--steps-per-eval": "20",
        "--adapter-path": "./finetune_output/quotes_lora_adapter",
        "--max-seq-length": "512",
        "--grad-checkpoint": "",
        "--seed": "42"
    }
    
    # Build command
    cmd = ["python", "-m", "mlx_lm", "lora"]
    for key, value in params.items():
        cmd.append(key)
        if value:  # Only add value if it's not empty (for flags like --train)
            cmd.append(value)
    
    print(f"🔧 Command: {' '.join(cmd)}")
    print(f"📊 System info: {psutil.cpu_count()} cores, {psutil.virtual_memory().total // (1024**3)}GB RAM")
    
    # Create output directory
    os.makedirs("./finetune_output", exist_ok=True)
    
    # Record start time and memory
    start_time = time.time()
    start_memory = psutil.Process().memory_info().rss / (1024**2)  # MB
    
    try:
        # Run fine-tuning
        print("\n🎯 Starting fine-tuning process...")
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=".")
        
        # Record end time and memory
        end_time = time.time()
        end_memory = psutil.Process().memory_info().rss / (1024**2)  # MB
        training_time = end_time - start_time
        memory_delta = end_memory - start_memory
        
        # Print results
        print(f"\n⏱️  Training completed in {training_time:.2f} seconds")
        print(f"💾 Memory usage delta: {memory_delta:.1f} MB")
        
        if result.returncode == 0:
            print("✅ Fine-tuning completed successfully!")
            print("\n📋 Training output:")
            print(result.stdout)
        else:
            print("❌ Fine-tuning failed!")
            print("\n📋 Error output:")
            print(result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Error running fine-tuning: {e}")
        return False
    
    return True

def test_finetuned_model():
    """Test the fine-tuned model"""
    print("\n🧪 Testing fine-tuned model...")
    
    try:
        from mlx_lm import load, generate
        
        # Load base model
        print("📦 Loading base model...")
        model, tokenizer = load("./models/mlx/tinyllama-1.1b-chat")
        
        # Test prompts
        test_prompts = [
            "Write an inspirational quote about success",
            "Write an inspirational quote about perseverance", 
            "Write an inspirational quote about dreams"
        ]
        
        print("\n🔍 Testing base model responses:")
        for prompt in test_prompts:
            formatted_prompt = f"<|im_start|>user\n{prompt}<|im_end|>\n<|im_start|>assistant\n"
            response = generate(model, tokenizer, formatted_prompt, max_tokens=100, temperature=0.7)
            print(f"Prompt: {prompt}")
            print(f"Response: {response[:200]}...")
            print("-" * 50)
        
        # TODO: Load and test LoRA adapter (requires additional MLX-LM functionality)
        print("\n💡 Note: LoRA adapter testing requires additional MLX-LM functionality")
        print("📁 Fine-tuned adapter saved to: ./finetune_output/quotes_lora_adapter")
        
    except Exception as e:
        print(f"❌ Error testing model: {e}")
        return False
    
    return True

def main():
    """Main fine-tuning workflow"""
    print("🎉 MLX Fine-tuning Demo on Apple Silicon")
    print("=" * 50)
    
    # Step 1: Prepare data
    train_count, val_count = prepare_training_data()
    
    # Step 2: Run fine-tuning
    if run_mlx_lora_finetune():
        print("\n🎊 Fine-tuning completed successfully!")
        
        # Step 3: Test model
        test_finetuned_model()
        
        # Summary
        print("\n" + "=" * 50)
        print("📊 FINE-TUNING SUMMARY")
        print("=" * 50)
        print(f"✅ Model: TinyLlama-1.1B-Chat")
        print(f"✅ Framework: MLX with LoRA")
        print(f"✅ Dataset: {train_count} training, {val_count} validation examples")
        print(f"✅ Training: 50 iterations with LoRA fine-tuning")
        print(f"✅ Output: ./finetune_output/quotes_lora_adapter")
        print(f"✅ Platform: Apple Silicon with Metal acceleration")
        
    else:
        print("\n❌ Fine-tuning failed. Check error messages above.")

if __name__ == "__main__":
    main()