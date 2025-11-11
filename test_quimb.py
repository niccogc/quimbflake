#!/usr/bin/env python3
"""Simple test to verify quimb package works correctly."""

import sys

def test_imports():
    """Test basic imports."""
    print("Testing imports...")
    import quimb
    import autoray
    import cotengra
    print("✓ All imports successful")

def test_basic_quimb():
    """Test basic quimb functionality."""
    print("\nTesting basic quimb functionality...")
    import quimb as qu
    
    # Create a simple quantum state (2^n dimension for n qubits)
    psi = qu.rand_ket(4)  # 4 = 2^2 for 2 qubits
    print(f"✓ Created random quantum state: {psi.shape}")
    
    # Create a simple operator for 2 qubits
    H = qu.ham_heis(2)
    print(f"✓ Created Heisenberg Hamiltonian: {H.shape}")
    
    # Simple expectation value
    energy = qu.expec(psi, H)
    print(f"✓ Computed expectation value: {energy}")

def main():
    """Run all tests."""
    print(f"Python version: {sys.version}")
    print("="*50)
    
    try:
        test_imports()
        test_basic_quimb()
        print("\n" + "="*50)
        print("All tests passed! ✓")
        return 0
    except Exception as e:
        print(f"\n✗ Test failed: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
