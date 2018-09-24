// build_test.cpp
// Version 3
// Chris Hartman
// For CS 411 Fall 2018 HW 2
// modified from:
//
// VERSION 2
// Glenn G. Chappell
// 29 Sep 2015
// Updated: 1 Oct 2015
//
// For CS 411/611 Fall 2015
// Test program for function build
// Used in Assignment 2, Exercise A

// Includes for code to be tested
#include "build.hpp"      // For function build
#include "build.hpp"      // Double inclusion test

// Includes for testing package & code common to all test programs
#include <iostream>     // for std::cout, std::endl, std::cin
#include <string>       // for std::string
#include <stdexcept>    // for std::runtime_error

// Additional includes for this test program
#include <vector>       // for std::vector
#include <cmath>        // for std::sqrt

// ************************************************************************
// Testing Package:
//     Class Tester - For Tracking Tests
// ************************************************************************


// class Tester
// For extremely simple unit testing.
// Keeps track of number of tests and number of passes.
// Use test (with success/failure parameter) to do a test.
// Get results with numTests, numPassed, numFailed, allPassed.
// Restart testing with reset.
// Invariants:
//     countTests_ == number of tests (calls to test) since last reset.
//     countPasses_ == number of times function test called with true param
//      since last reset.
//     0 <= countPasses_ <= countTests_.
//     tolerance_ >= 0.
class Tester {

// ***** Tester: ctors, dctor, op= *****
public:

    // Default ctor
    // Sets countTests_, countPasses_ to zero, tolerance_ to given value
    // Pre: None.
    // Post:
    //     numTests == 0, countPasses == 0, tolerance_ == abs(theTolerance)
    // Does not throw (No-Throw Guarantee)
    Tester(double theTolerance = 0.0000001)
        :countTests_(0),
         countPasses_(0),
         tolerance_(theTolerance >= 0 ? theTolerance : -theTolerance)
    {}

    // Compiler-generated copy ctor, copy op=, dctor are used

// ***** Tester: general public functions *****
public:

    // test
    // Handles single test, param indicates pass/fail
    // Pre: None.
    // Post:
    //     countTests_ incremented
    //     countPasses_ incremented if (success)
    //     Message indicating test name (if given)
    //      and pass/fail printed to cout
    // Does not throw (No-Throw Guarantee)
    //  - Assuming exceptions have not been turned on for cout.
    void test(bool success,
              const std::string & testName = "")
    {
        ++countTests_;
        if (success) ++countPasses_;

        std::cout << "    ";
        if (testName != "")
        {
            std::cout << "Test: "
                      << testName
                      << " - ";
        }
        std::cout << (success ? "passed" : "********** FAILED **********")
                  << std::endl;
    }

    // ftest
    // Does single floating-point test.
    // Tests passes iff difference of first two values is <= tolerance.
    // Pre: None.
    // Post:
    //     countTests_ incremented
    //     countPasses_ incremented if (abs(val1-val2) <= tolerance_)
    //     Message indicating test name (if given)
    //      and pass/fail printed to cout
    // Does not throw (No-Throw Guarantee)
    void ftest(double val1,
               double val2,
               const std::string & testName = "")
    { test(val1-val2 <= tolerance_ && val2-val1 <= tolerance_, testName); }

    // reset
    // Resets *this to default constructed state
    // Pre: None.
    // Post:
    //     countTests_ == 0, countPasses_ == 0
    // Does not throw (No-Throw Guarantee)
    void reset()
    {
        countTests_ = 0;
        countPasses_ = 0;
    }

    // numTests
    // Returns the number of tests that have been done since last reset
    // Pre: None.
    // Post:
    //     return == countTests_
    // Does not throw (No-Throw Guarantee)
    int numTests() const
    { return countTests_; }

    // numPassed
    // Returns the number of tests that have passed since last reset
    // Pre: None.
    // Post:
    //     return == countPasses_
    // Does not throw (No-Throw Guarantee)
    int numPassed() const
    { return countPasses_; }

    // numFailed
    // Returns the number of tests that have not passed since last reset
    // Pre: None.
    // Post:
    //     return + countPasses_ == numTests_
    // Does not throw (No-Throw Guarantee)
    int numFailed() const
    { return countTests_ - countPasses_; }

    // allPassed
    // Returns true if all tests since last reset have passed
    // Pre: None.
    // Post:
    //     return == (countPasses_ == countTests_)
    // Does not throw (No-Throw Guarantee)
    bool allPassed() const
    { return countPasses_ == countTests_; }

    // setTolerance
    // Sets tolerance_ to given value
    // Pre: None.
    // Post:
    //     tolerance_ = abs(theTolerance)
    // Does not throw (No-Throw Guarantee)
    void setTolerance(double theTolerance)
    { tolerance_ = (theTolerance >= 0 ? theTolerance : -theTolerance); }

// ***** Tester: data members *****
private:

    int countTests_;    // Number of tests done since last reset
    int countPasses_;   // Number of tests passed since last reset
    double tolerance_;  // Tolerance for floating-point near-equality tests

};  // end class Tester


// ************************************************************************
// Testing Package:
//     Class TypeCheck - Helper Class for Type Checking
// ************************************************************************


// class TypeCheck
// This class exists in order to have static member function check, which
// takes a parameter of a given type, by reference. Objects of type
// TypeCheck<T> cannot be created.
// Usage:
//     TypeCheck<MyType>::check(x)
//     returns true if the type of x is (MyType) or (const MyType),
//     otherwise false.
// Invariants: None.
// Requirements on Types: None.
template<typename T>
class TypeCheck {

private:

    // Uncopyable class. Do not define copy ctor, copy assn.
    TypeCheck(const TypeCheck &);
    TypeCheck<T> & operator=(const TypeCheck &);

    // Compiler-generated dctor is used (but irrelevant).

public:

    // check
    // The function and function template below simulate a single function
    // that takes a single parameter, and returns true iff the parameter has
    // type T or (const T).

    // check (reference-to-const T)
    // Pre: None.
    // Post:
    //     Return is true.
    // Does not throw (No-Throw Guarantee)
    static bool check(const T & param)
    { return true; }

    // check (reference-to-const non-T)
    // Pre: None.
    // Post:
    //     Return is false.
    // Requirements on types: None.
    // Does not throw (No-Throw Guarantee)
    template <typename OtherType>
    static bool check(const OtherType & param)
    { return false; }

};  // End class TypeCheck


// ************************************************************************
// Testing Package:
//     Class Counter - Helper Class for Counting Calls & Objects, Throwing
// ************************************************************************


// class Counter
// Item type for counting ctor, dctor, op= calls, counting existing
//  objects, and possibly throwing on copy. Has operator< (which always
//  returns false), allowing it to be the value type of a sorted container.
// If static member copyThrow_ is set, then copy ctor and copy assn throw
//  std::runtime_error. Exception object's "what" member is set to "C" by
//  the copy ctor and "A" by copy assn.
// Increments static data member ctorCount_ on default construction and
//  successful copy construction. Increments static data member assnCount_
//  on successful copy assignment. Increments static data member
//  dctorCount_ on destruction.
// Increments static data member existing_ on construction, and decrements
//  it on destruction.
// Static data member maxExisting_ is highest value of existing_ since last
//  reset, or start of program if reset has never been called.
// Invariants:
//     Counter::existing_ is number of existing objects of this class.
//     Counter::ctorCount_ is number of successful ctor calls since
//      most recent call to reset, or start of program if reset has never
//      been called.
//     Counter::dctorCount_ is (similarly) number of dctor calls.
//     Counter::assnCount_ is (similarly) number of copy assn calls.
//     Counter::maxExisting_ is (similarly) highest value existing_ has
//      assumed.
class Counter {

// ***** Counter: Ctors, dctor, op= *****
public:

    // Default ctor
    // Pre: None.
    // Post:
    //     (ctorCount_ has been incremented.)
    //     (existing_ has been incremented.)
    // Does not throw (No-Throw Guarantee)
    Counter()
    {
        ++existing_;
        if (existing_ > maxExisting_)
            maxExisting_ = existing_;
        ++ctorCount_;
    }

    // Copy ctor
    // Throws std::runtime_error if copyThrow_.
    // Pre: None.
    // Post:
    //     (ctorCount_ has been incremented.)
    //     (existing_ has been incremented.)
    // May throw std::runtime_error
    // Strong Guarantee
    Counter(const Counter & other)
    {
        if (copyThrow_)
            throw std::runtime_error("C");
        ++existing_;
        if (existing_ > maxExisting_)
            maxExisting_ = existing_;
        ++ctorCount_;
    }

    // Copy assignment
    // Throws std::runtime_error if copyThrow_.
    // Pre: None.
    // Post:
    //     Return value is *this.
    //     (assnCount_ has been incremented.)
    // May throw std::runtime_error
    // Strong Guarantee
    Counter & operator=(const Counter & rhs)
    {
        if (copyThrow_)
            throw std::runtime_error("A");
        ++assnCount_;
        return *this;
    }

    // Dctor
    // Pre: None.
    // Post:
    //     (dctorCount_ has been incremented.)
    //     (existing_ has been decremented.)
    // Does not throw (No-Throw Guarantee)
    ~Counter()
    {
        --existing_;
        ++dctorCount_;
    }

// ***** Counter: Functions dealing with count *****
public:

    // reset
    // Pre: None.
    // Post:
    //     maxExisting_ == existing_.
    //     ctorCount_ == 0.
    //     dctorCount_ == 0.
    //     assnCount_ == 0.
    //     copyThrow_ == shouldThrow.
    // Does not throw (No-Throw Guarantee)
    static void reset(bool shouldThrow = false)
    {
        maxExisting_ = existing_;
        ctorCount_ = 0;
        dctorCount_ = 0;
        assnCount_ = 0;
        copyThrow_ = shouldThrow;
    }

    // getExisting
    // Pre: None.
    // Post:
    //     return == existing_.
    // Does not throw (No-Throw Guarantee)
    static int getExisting()
    { return existing_; }

    // getMaxExisting
    // Pre: None.
    // Post:
    //     return == maxExisting_.
    // Does not throw (No-Throw Guarantee)
    static int getMaxExisting()
    { return maxExisting_; }

    // getCtorCount
    // Pre: None.
    // Post:
    //     return == ctorCount_.
    // Does not throw (No-Throw Guarantee)
    static int getCtorCount()
    { return ctorCount_; }

    // getDctorCount
    // Pre: None.
    // Post:
    //     return == dctorCount_.
    // Does not throw (No-Throw Guarantee)
    static int getDctorCount()
    { return dctorCount_; }

    // getAssnCount
    // Pre: None.
    // Post:
    //     return == assnCount_.
    // Does not throw (No-Throw Guarantee)
    static int getAssnCount()
    { return assnCount_; }

    // setCopyThrow
    // Pre: None.
    // Post:
    //     copyThrow_ == shouldThrow
    // Does not throw (No-Throw Guarantee)
    static void setCopyThrow(bool shouldThrow)
    { copyThrow_ = shouldThrow; }

// ***** Counter: Data Members *****
private:

    static int existing_;     // # of existing objects
    static int maxExisting_;  // Max # of existing objects
    static int ctorCount_;    // # of successful (non-throwing) ctor calls
    static int dctorCount_;   // # of dctor calls
    static int assnCount_;    // # of successful (non-throwing) copy = calls
    static bool copyThrow_;   // true if copy operations (ctor, =) throw

};  // End class Counter

// Definition of static data member of class Counter
int Counter::existing_ = 0;
int Counter::maxExisting_ = 0;
int Counter::ctorCount_ = 0;
int Counter::dctorCount_ = 0;
int Counter::assnCount_ = 0;
bool Counter::copyThrow_ = false;


// operator< (Counter)
// Dummy-ish operator<, forming a strict weak order for Counter class
// Returns false (which is legal for a strict weak order; all objects of
//  type Counter are equivalent).
// Pre: None.
// Post:
//     Return value == false.
// Does not throw (No-Throw Guarantee)
bool operator<(const Counter & a,
               const Counter & b)
{ return false; }


// ************************************************************************
// Helper Functions/Classes/Types for This Test Program
// ************************************************************************


// Type for a bridge description; must have size 3
using Brg = std::vector<int>;


// test_build_single
// Do a single test for function build. Given parameters, expected return
// value, and test name. Prints results, along with expected return value
// if test fails.
// Pre: None.
// Post:
//     Pass/fail status of tests have been registered with t.
//     Appropriate messages have been printed to cout.
// Does not throw (No-Throw Guarantee)
void test_build_single(Tester & t,
                       int w,    // Number of west-bank cities
                       int e,    // Number of east-bank cities
                       const std::vector<Brg> & cbs,
                                 // List of bridges
                       int ans,  // Expected return value
                       const std::string & testName)
{
    int retval = build(w, e, cbs);   // Get return value of function
    bool success = (retval == ans);
    t.test(success, testName);
    if (!success)
    {
        std::cout << "      Expected return value: " << ans
                  << std::endl;
        std::cout << "      Actual return value: " << retval
                  << std::endl;
    }
}


// ************************************************************************
// Test Suite Functions
// ************************************************************************


// test_build_tiny
// Test suite for function build: tiny examples
// Pre: None.
// Post:
//     Pass/fail status of tests have been registered with t.
//     Appropriate messages have been printed to cout.
// Does not throw (No-Throw Guarantee)
void test_build_tiny(Tester & t)
{
    std::cout << "Test Suite: function build - tiny examples"
              << std::endl;

    std::vector<Brg> bs;               // Bridge descriptions
    const std::vector<Brg> & cbs(bs);  // Const ref to above
    int w;                             // Number of west cities
    int e;                             // Number of west cities
    int ans;                           // Desired answer

    // Empty list of bridges
    {
        w = 1;
        e = 1;
        bs.clear();
        ans = 0;
        test_build_single(t, w, e, cbs, ans,
            "No bridges");
    }

    // 1 bridge
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 2, 13 });
        ans = 13;
        test_build_single(t, w, e, cbs, ans,
            "1 bridge");
    }

    // 2 bridges, non-crossing
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 0, 6 });
        bs.push_back(Brg { 3, 4, 5 });
        ans = 11;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, non-crossing");
    }

    // 2 bridges, common west city, N is best
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 0, 8 });
        bs.push_back(Brg { 2, 3, 4 });
        ans = 8;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common west city, N is best");
    }

    // 2 bridges, common west city, N is best (reordered)
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 3, 4 });
        bs.push_back(Brg { 2, 0, 8 });
        ans = 8;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common west city, N is best (reordered)");
    }

    // 2 bridges, common west city, S is best
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 0, 2 });
        bs.push_back(Brg { 2, 3, 6 });
        ans = 6;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common west city, S is best");
    }

    // 2 bridges, common west city, S is best (reordered)
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 3, 6 });
        bs.push_back(Brg { 2, 0, 2 });
        ans = 6;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common west city, S is best (reordered)");
    }

    // 2 bridges, common east city, N is best
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 1, 3, 5 });
        bs.push_back(Brg { 2, 3, 2 });
        ans = 5;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common east city, N is best");
    }

    // 2 bridges, common east city, N is best (reordered)
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 3, 2 });
        bs.push_back(Brg { 1, 3, 5 });
        ans = 5;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common east city, N is best (reordered)");
    }

    // 2 bridges, common east city, S is best
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 3, 1 });
        bs.push_back(Brg { 1, 3, 7 });
        ans = 7;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common east city, S is best");
    }

    // 2 bridges, common east city, S is best (reordered)
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 3, 1 });
        bs.push_back(Brg { 1, 3, 7 });
        ans = 7;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, common east city, S is best (reordered)");
    }

    // 2 bridges, identical
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 2, 5 });
        bs.push_back(Brg { 0, 2, 5 });
        ans = 5;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, identical");
    }

    // 2 bridges, same cities, different tolls (reordered)
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 2, 5 });
        bs.push_back(Brg { 0, 2, 6 });
        ans = 6;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, same cities, different tolls (reordered)");
    }

    // 2 bridges, same cities, different tolls
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 2, 6 });
        bs.push_back(Brg { 0, 2, 5 });
        ans = 6;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, same cities, different tolls");
    }

    // 2 bridges, crossing, NW-SE is best
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 1, 6 });
        bs.push_back(Brg { 2, 0, 5 });
        ans = 6;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, crossing, NW-SE is best");
    }

    // 2 bridges, crossing, NW-SE is best (reordered)
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 0, 5 });
        bs.push_back(Brg { 0, 1, 6 });
        ans = 6;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, crossing, NW-SE is best (reordered)");
    }

    // 2 bridges, crossing, SW-NE is best
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 0, 1, 5 });
        bs.push_back(Brg { 2, 0, 7 });
        ans = 7;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, crossing, SW-NE is best");
    }

    // 2 bridges, crossing, SW-NE is best (reordered)
    {
        w = 5;
        e = 5;
        bs.clear();
        bs.push_back(Brg { 2, 0, 7 });
        bs.push_back(Brg { 0, 1, 5 });
        ans = 7;
        test_build_single(t, w, e, cbs, ans,
            "2 bridges, crossing, SW-NE is best (reordered)");
    }
}


// test_build_small
// Test suite for function build: small examples
// Pre: None.
// Post:
//     Pass/fail status of tests have been registered with t.
//     Appropriate messages have been printed to cout.
// Does not throw (No-Throw Guarantee)
void test_build_small(Tester & t)
{
    std::cout << "Test Suite: function build - small examples"
              << std::endl;

    std::vector<Brg> bs;               // Bridge descriptions
    const std::vector<Brg> & cbs(bs);  // Const ref to above
    int w;                             // Number of west cities
    int e;                             // Number of west cities
    int ans;                           // Desired answer

    // Example #1 from assignment description
    {
        w = 3;
        e = 3;
        bs.clear();
        bs.push_back(Brg { 0, 1, 3 });
        bs.push_back(Brg { 1, 1, 5 });
        bs.push_back(Brg { 1, 2, 4 });
        bs.push_back(Brg { 2, 0, 8 });
        ans = 8;
        test_build_single(t, w, e, cbs, ans,
            "Example #1 from assignment description");
    }

    // Example #2 from assignment description
    {
        w = 3;
        e = 3;
        bs.clear();
        bs.push_back(Brg { 0, 1, 3 });
        bs.push_back(Brg { 1, 1, 5 });
        bs.push_back(Brg { 1, 2, 4 });
        bs.push_back(Brg { 2, 0, 8 });
        bs.push_back(Brg { 2, 2, 6 });
        ans = 11;
        test_build_single(t, w, e, cbs, ans,
            "Example #2 from assignment description");
    }

    // 3 cities each side, not all joinable
    {
        w = 3;
        e = 3;
        bs.clear();
        bs.push_back(Brg { 0, 0, 4 });
        bs.push_back(Brg { 1, 0, 4 });
        bs.push_back(Brg { 2, 0, 4 });
        bs.push_back(Brg { 2, 1, 4 });
        bs.push_back(Brg { 2, 2, 4 });
        ans = 8;
        test_build_single(t, w, e, cbs, ans,
            "3 cities each side, not all joinable");
    }

    // 3 cities each side, all joinable
    {
        w = 3;
        e = 3;
        bs.clear();
        bs.push_back(Brg { 0, 0, 4 });
        bs.push_back(Brg { 1, 0, 4 });
        bs.push_back(Brg { 2, 0, 4 });
        bs.push_back(Brg { 2, 1, 4 });
        bs.push_back(Brg { 2, 2, 4 });
        bs.push_back(Brg { 1, 1, 4 });
        ans = 12;
        test_build_single(t, w, e, cbs, ans,
            "3 cities each side, all joinable");
    }
}


// test_build_medium
// Test suite for function build: medium examples
// Pre: None.
// Post:
//     Pass/fail status of tests have been registered with t.
//     Appropriate messages have been printed to cout.
// Does not throw (No-Throw Guarantee)
void test_build_medium(Tester & t)
{
    std::cout << "Test Suite: function build - medium examples"
              << std::endl;

    std::vector<Brg> bs;               // Brg descriptions
    const std::vector<Brg> & cbs(bs);  // Const ref to above
    int w;                             // Number of west cities
    int e;                             // Number of west cities
    int ans;                           // Desired answer

    // Greedy fails
    {
        w = 4;
        e = w;
        bs.clear();
        bs.push_back(Brg {  0,  1,  1 });
        bs.push_back(Brg {  1,  0,  2 });
        bs.push_back(Brg {  2,  3,  1 });
        bs.push_back(Brg {  3,  2,  2 });
        test_build_single(t, w, e, cbs, 4,
                          "Greedy fails");
    }
    
    // Greedy fails large
    {
        w = 20;
        e = w;
        bs.clear();
        auto phi = (1+sqrt(5)/2);
        auto phipower = phi;
        for(auto i=0;i<w/2;++i) {
            if (fmod(1,phipower) > 0.5) {
                bs.push_back(Brg {  2*i,  2*i+1,  1 });
                bs.push_back(Brg {  2*i+1,  2*i,  2 });
            } else {
                bs.push_back(Brg {  2*i,  2*i+1,  2 });
                bs.push_back(Brg {  2*i+1,  2*i,  1 });
            }
            phipower *= phi;
        }
        ans = w;
        test_build_single(t, w, e, cbs, ans,
                          "Greedy fails large");
    }
    
    // All bridges available #1
    {
        w = 4;
        e = w;
        bs.clear();
        for (int i = 0; i < w; ++i)
            for (int j = 0; j < e; ++j)
                bs.push_back(Brg { i, j, 3 });
        ans = w * 3;
        test_build_single(t, w, e, cbs, ans,
            "All bridges available #1");
    }

    // All bridges available #2
    {
        w = 4;
        e = w;
        bs.clear();
        for (int i = 0; i < w; ++i)
            for (int j = 0; j < e; ++j)
                bs.push_back(Brg { i, j, (i == j ? 3 : 5) });
        ans = (w-1) * 5;
        test_build_single(t, w, e, cbs, ans,
            "All bridges available #2");
    }

    // All bridges available #3
    {
        w = 4;
        e = w;
        bs.clear();
        for (int i = w-1; i >= 0; --i)
            for (int j = e-1; j >= 0; --j)
                bs.push_back(Brg { i, j, (-1 <= i-j && i-j <= 1 ? 3 : 7) });
        ans = (w-2) * 7;
        test_build_single(t, w, e, cbs, ans,
            "All bridges available #3");
    }

    // Random #1
    {
        w = 12;
        e = 12;
        bs.clear();
        bs.push_back(Brg {  2, 10,  5 });
        bs.push_back(Brg {  4,  0,  5 });
        bs.push_back(Brg {  1,  1,  7 });
        bs.push_back(Brg { 11,  2,  7 });
        bs.push_back(Brg {  2,  6,  5 });
        bs.push_back(Brg {  0,  5,  7 });
        bs.push_back(Brg {  7,  8,  5 });
        bs.push_back(Brg { 10,  1,  5 });
        bs.push_back(Brg {  8, 11,  7 });
        bs.push_back(Brg {  9,  3,  5 });
        bs.push_back(Brg {  3,  7,  7 });
        bs.push_back(Brg {  5,  4,  7 });
        bs.push_back(Brg {  8,  9,  7 });
        bs.push_back(Brg {  3,  7,  5 });
        bs.push_back(Brg {  6, 11,  5 });
        bs.push_back(Brg {  9,  4,  7 });
        ans = 31;
        test_build_single(t, w, e, cbs, ans,
            "Random #1");
    }

    // Random #2
    {
        w = 12;
        e = 12;
        bs.clear();
        bs.push_back(Brg {  4,  8,  2 });
        bs.push_back(Brg { 11,  6,  2 });
        bs.push_back(Brg {  2, 11,  4 });
        bs.push_back(Brg {  5,  7,  2 });
        bs.push_back(Brg {  9,  1,  4 });
        bs.push_back(Brg {  6,  4,  2 });
        bs.push_back(Brg {  0,  1,  4 });
        bs.push_back(Brg {  3,  5,  4 });
        bs.push_back(Brg {  4,  9,  4 });
        bs.push_back(Brg {  3, 10,  2 });
        bs.push_back(Brg {  8,  9,  2 });
        bs.push_back(Brg {  3,  2,  4 });
        bs.push_back(Brg {  8, 11,  2 });
        bs.push_back(Brg { 10,  2,  4 });
        bs.push_back(Brg {  1,  0,  2 });
        bs.push_back(Brg {  7,  7,  4 });
        ans = 16;
        test_build_single(t, w, e, cbs, ans,
            "Random #2");
    }

    // Random #3
    {
        w = 12;
        e = 12;
        bs.clear();
        bs.push_back(Brg {  7, 11,  6 });
        bs.push_back(Brg {  9,  4,  7 });
        bs.push_back(Brg {  6,  9,  7 });
        bs.push_back(Brg {  8,  1,  6 });
        bs.push_back(Brg {  0,  7,  6 });
        bs.push_back(Brg {  3,  6,  7 });
        bs.push_back(Brg {  5,  3,  6 });
        bs.push_back(Brg { 11,  2,  7 });
        bs.push_back(Brg { 10,  0,  7 });
        bs.push_back(Brg {  2,  7,  7 });
        bs.push_back(Brg {  1, 10,  7 });
        bs.push_back(Brg {  4,  9,  6 });
        bs.push_back(Brg {  5,  1,  6 });
        bs.push_back(Brg {  4,  2,  7 });
        bs.push_back(Brg {  8, 11,  6 });
        bs.push_back(Brg {  3,  8,  6 });
        ans = 26;
        test_build_single(t, w, e, cbs, ans,
            "Random #3");
    }

    // One bridge crosses many #1
    {
        w = 12;
        e = w;
        bs.clear();
        for (int i = 0; i < w; ++i)
            bs.push_back(Brg { i, i, 1 });
        bs.push_back(Brg { 0, e-1, w+1 });
        bs.push_back(Brg { w-1, 0, w+2 });

        ans = w+2;
        test_build_single(t, w, e, cbs, ans,
            "One bridge crosses many #1");
    }

    // One bridge crosses many #2
    {
        w = 12;
        e = w;
        bs.clear();
        for (int i = 0; i < w; ++i)
            bs.push_back(Brg { i, i, 1 });
        bs.push_back(Brg { 0, e-1, w-1 });
        bs.push_back(Brg { w-1, 0, w-2 });

        ans = w;
        test_build_single(t, w, e, cbs, ans,
            "One bridge crosses many #2");
    }
}


// test_build
// Test suite for function build
// Uses other test-suite functions
// Pre: None.
// Post:
//     Pass/fail status of tests have been registered with t.
//     Appropriate messages have been printed to cout.
// Does not throw (No-Throw Guarantee)
void test_build(Tester & t)
{
    // Do all the test suites
    std::cout << "TEST SUITES FOR FUNCION build" << std::endl;
    test_build_tiny(t);
    test_build_small(t);
    test_build_medium(t);
}


// ************************************************************************
// Main program
// ************************************************************************


// main
// Runs function build test suite, prints results to cout.
int main()
{
    Tester t;
    test_build(t);

    std::cout << std::endl;
    if (t.allPassed())
    {
        std::cout << "All tests successful"
                  << std::endl;
    }
    else
    {
        std::cout << "Tests ********** UNSUCCESSFUL **********"
                  << std::endl;
    }
    std::cout << std::endl;

    // Wait for user
    std::cout << "Press ENTER to quit ";
    while (std::cin.get() != '\n') ;

    return 0;
}

