#!/usr/bin/env python3
# test-installation.py - Script to verify MLX installation on Apple Silicon

import sys
import platform
import time
import os
import subprocess
from pathlib import Path

def print_section(title):
    """Print a section title with formatting."""
    print(f"\n{'-' * 80}")
    print(f"  {title}")
    print(f"{'-' * 80}")

def check_system():
    """Check system information."""
    print_section("System Information")
    
    print(f"Python version: {sys.version.split()[0]}")
    print(f"Platform: {platform.platform()}")
    print(f"Processor: {platform.processor()}")
    
    # Check if running on Apple Silicon
    is_arm64 = platform.machine() == "arm64"
    print(f"Apple Silicon: {'Yes' if is_arm64 else 'No'}")
    
    if not is_arm64:
        print("\n⚠️  Warning: This script is designed for Apple Silicon Macs.")
        print("   Performance may not be optimal on this system.")
    
    # Get more detailed CPU info on macOS
    if platform.system() == "Darwin":
        cpu_brand = subprocess.getoutput("sysctl -n machdep.cpu.brand_string")
        print(f"CPU: {cpu_brand}")
    
    # Check available memory
    if platform.system() == "Darwin":
        memory_info = subprocess.getoutput("sysctl -n hw.memsize")
        try:
            memory_gb = int(memory_info) / (1024**3)
            print(f"Memory: {memory_gb:.1f} GB")
            
            if memory_gb < 8:
                print("⚠️  Warning: Less than 8GB RAM detected. Some models may not run properly.")
            elif memory_gb < 16:
                print("ℹ️  Note: 8-16GB RAM detected. Recommended to use INT4 quantization for 7B models.")
        except ValueError:
            print("Memory: Unable to determine")
    
    return is_arm64

def check_python_packages():
    """Check if required Python packages are installed."""
    print_section("Python Package Check")
    
    required_packages = ["mlx", "mlx_lm"]
    missing_packages = []
    package_versions = {}
    
    for package in required_packages:
        try:
            # Try to import the package
            module = __import__(package.replace('-', '_'))
            
            # Get version if available
            version = getattr(module, "__version__", "unknown")
            package_versions[package] = version
            print(f"✓ {package} is installed (version: {version})")
        except ImportError:
            missing_packages.append(package)
            print(f"✗ {package} is not installed")
    
    if missing_packages:
        print("\n⚠️  Some required packages are missing.")
        print("   Please run the setup script or install them manually:")
        print(f"   pip install {' '.join(missing_packages)}")
        return False
    
    return True

def test_basic_mlx():
    """Test basic MLX functionality."""
    print_section("Basic MLX Test")
    
    try:
        import mlx.core as mx
        import numpy as np
        
        # Create a simple array
        print("Creating test arrays...")
        a = mx.array([[1, 2, 3], [4, 5, 6]])
        b = mx.array([[7, 8, 9], [10, 11, 12]])
        
        # Perform simple operations
        print("Testing basic operations...")
        c = mx.add(a, b)
        d = mx.matmul(a, mx.transpose(b))
        
        # Convert back to numpy for printing
        c_np = np.array(c)
        d_np = np.array(d)
        
        print(f"Addition result: {c_np.tolist()}")
        print(f"Matrix multiplication result: {d_np.tolist()}")
        
        # Check if results are correct
        expected_c = np.array([[8, 10, 12], [14, 16, 18]])
        expected_d = np.array([[50, 68], [122, 167]])
        
        c_correct = np.allclose(c_np, expected_c)
        d_correct = np.allclose(d_np, expected_d)
        
        if c_correct and d_correct:
            print("✓ Basic operations test passed")
            return True
        else:
            print("✗ Basic operations test failed")
            return False
    
    except Exception as e:
        print(f"✗ MLX test failed with error: {str(e)}")
        return False

def test_metal_performance():
    """Test Metal acceleration performance."""
    print_section("Metal Performance Test")
    
    try:
        import mlx.core as mx
        
        # Check if Metal is available
        metal_available = mx.metal.is_available()
        print(f"Metal acceleration available: {'Yes' if metal_available else 'No'}")
        
        if not metal_available:
            print("⚠️  Metal acceleration is not available.")
            print("   This could be because:")
            print("   - You're not running on Apple Silicon")
            print("   - There's an issue with your Metal setup")
            print("   - MLX was not built with Metal support")
            return False
        
        # Create large arrays for performance testing
        size = 1000
        print(f"Testing performance with {size}x{size} matrices...")
        
        # Test on CPU
        mx.set_default_device(mx.cpu)
        a_cpu = mx.random.normal((size, size))
        b_cpu = mx.random.normal((size, size))
        
        print("Running on CPU...")
        start_time = time.time()
        c_cpu = mx.matmul(a_cpu, b_cpu)
        mx.eval(c_cpu)
        cpu_time = time.time() - start_time
        print(f"CPU time: {cpu_time:.4f} seconds")
        
        # Test on GPU (Metal)
        mx.set_default_device(mx.gpu)
        a_gpu = mx.random.normal((size, size))
        b_gpu = mx.random.normal((size, size))
        
        print("Running on GPU (Metal)...")
        start_time = time.time()
        c_gpu = mx.matmul(a_gpu, b_gpu)
        mx.eval(c_gpu)
        gpu_time = time.time() - start_time
        print(f"GPU time: {gpu_time:.4f} seconds")
        
        # Compare performance
        if cpu_time > 0 and gpu_time > 0:
            speedup = cpu_time / gpu_time
            print(f"Metal speedup: {speedup:.2f}x")
            
            if speedup >= 1.5:
                print("✓ Metal acceleration is working correctly")
                return True
            else:
                print("⚠️  Metal acceleration is working but performance is lower than expected")
                print("   This could be due to overhead for small matrices or other system factors")
                return True  # Still return True since Metal is working
        else:
            print("⚠️  Could not accurately measure performance")
            return False
    
    except Exception as e:
        print(f"✗ Metal test failed with error: {str(e)}")
        return False

def test_mlx_lm():
    """Test MLX-LM functionality."""
    print_section("MLX-LM Test")
    
    try:
        from mlx_lm.utils import get_model_path
        
        print("Testing MLX-LM utilities...")
        
        # Test model path resolution without actually downloading
        print("Checking model path resolution...")
        try:
            # This just checks if the function exists and runs
            # It won't actually download anything if the model doesn't exist locally
            get_model_path("test_model_name", download=False)
            print("✓ Model path resolution is working")
            return True
        except Exception as e:
            if "No such file or directory" in str(e):
                # This is expected if the model doesn't exist
                print("✓ Model path resolution is working")
                return True
            else:
                print(f"✗ Model path resolution failed with error: {str(e)}")
                return False
    
    except Exception as e:
        print(f"✗ MLX-LM test failed with error: {str(e)}")
        return False

def check_directories():
    """Check if necessary directories exist."""
    print_section("Directory Check")
    
    # Get the script directory
    script_dir = Path(__file__).resolve().parent
    base_dir = script_dir.parent
    
    directories = {
        "scripts": base_dir / "scripts",
        "docs": base_dir / "docs",
        "models": base_dir / "models"
    }
    
    all_exist = True
    for name, path in directories.items():
        if path.exists() and path.is_dir():
            print(f"✓ {name} directory exists: {path}")
        else:
            print(f"✗ {name} directory missing: {path}")
            all_exist = False
    
    return all_exist

def summarize_results(results):
    """Summarize test results."""
    print_section("Test Results")
    
    passed = sum(1 for result in results.values() if result)
    total = len(results)
    
    print(f"Passed: {passed}/{total} tests")
    
    for test, result in results.items():
        status = "✓ Passed" if result else "✗ Failed"
        print(f"{status}: {test}")
    
    if passed == total:
        print("\n✅ All tests passed! MLX is correctly installed.")
    else:
        print(f"\n⚠️  {total - passed} tests failed. Please check the issues above.")

def main():
    """Main function to run all tests."""
    print("MLX Installation Test for Apple Silicon")
    print("======================================")
    
    results = {}
    
    # Run tests
    results["System Check"] = check_system()
    results["Python Packages"] = check_python_packages()
    
    # Only continue with MLX tests if packages are installed
    if results["Python Packages"]:
        results["Basic MLX"] = test_basic_mlx()
        results["Metal Performance"] = test_metal_performance()
        results["MLX-LM"] = test_mlx_lm()
    
    results["Directory Structure"] = check_directories()
    
    # Summarize results
    summarize_results(results)
    
    # Return exit code based on test results
    return 0 if all(results.values()) else 1

if __name__ == "__main__":
    sys.exit(main())