import os

from sage.interfaces.four_ti_2 import four_ti_2, FourTi2

# Test 0
four_ti_2.write_matrix([[6,10,15]], "test_file")
four_ti_2.call("groebner", "test_file", False) # optional - 4ti2
assert four_ti_2.read_matrix("test_file.gro") == Matrix([[-5, 0, 2], [-5, 3, 0]]), "Test 0 Failed!"
print("Passed Test 0")

# Test 1
assert four_ti_2.circuits([1,2,3]) == Matrix([[0, 3, -2], [2, -1, 0], [3, 0, -1]]), "Test 1 Failed!"
print("Passed Test 1")

# Test 2
f = FourTi2("/tmp/")
assert f.directory() == "/tmp/", "Test 2 Failed!"
print("Passed Test 2")

# Test 3
assert four_ti_2.graver([1,2,3]) == Matrix([[2, -1, 0],
                                            [3, 0, -1],
                                            [1, 1, -1],
                                            [1, -2, 1],
                                            [0, 3, -2]]), "Test 3 Failed!"
assert four_ti_2.graver(lat=[[1,2,3],[1,1,1]]) == Matrix([[1, 0, -1],
                                                          [0, 1,  2],
                                                          [1, 1,  1],
                                                          [2, 1,  0]]), "Test 3 Failed!"
print("Passed Test 3")

# Test 4
A = [6,10,15]
assert four_ti_2.groebner(A) == Matrix([[-5, 0, 2], [-5, 3, 0]]), "Test 4 Failed!"
assert four_ti_2.groebner(lat=[[1,2,3],[1,1,1]]) == Matrix([[-1, 0, 1], [2, 1, 0]]), "Test 4 Failed!"
print("Passed Test 4")

# Test 5
assert four_ti_2.hilbert(four_ti_2._magic3x3()) == Matrix([
                            [2, 0, 1, 0, 1, 2, 1, 2, 0],
                            [1, 0, 2, 2, 1, 0, 0, 2, 1],
                            [0, 2, 1, 2, 1, 0, 1, 0, 2],
                            [1, 2, 0, 0, 1, 2, 2, 0, 1],
                            [1, 1, 1, 1, 1, 1, 1, 1, 1]]), "Test 5 Failed!"
assert four_ti_2.hilbert(lat=[[1, 2, 3], [1, 1, 1]]) == Matrix([[2, 1, 0], 
                                                                [0, 1, 2],
                                                                [1, 1, 1]]), "Test 5 Failed!"
print("Passed Test 5")

# Test 6
assert four_ti_2.ppi(3) == Matrix([[-2, 1, 0],
                                   [0, -3, 2],
                                   [-1, -1, 1],
                                   [-3, 0, 1],
                                   [1, -2, 1]]), "Test 6 Failed!"
print("Passed Test 6")

# Test 7
assert four_ti_2.rays(four_ti_2._magic3x3()) == Matrix([
                            [0, 2, 1, 2, 1, 0, 1, 0, 2],
                            [1, 0, 2, 2, 1, 0, 0, 2, 1],
                            [1, 2, 0, 0, 1, 2, 2, 0, 1],
                            [2, 0, 1, 0, 1, 2, 1, 2, 0]]), "Test 8 Failed!"
print("Passed Test 7")
print("All Tests Passed!")
