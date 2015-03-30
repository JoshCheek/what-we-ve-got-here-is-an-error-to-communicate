
  From: http://blog.nicksieger.com/articles/2006/09/06/rubys-exception-hierarchy/
  Exception
   NoMemoryError
   ScriptError
     LoadError
     NotImplementedError
     SyntaxError
   SignalException
     Interrupt
   StandardError
     ArgumentError       (IN PROGRESS)
     IOError
       EOFError
     IndexError
     LocalJumpError
     NameError
       NoMethodError     (IN PROGRESS)
     RangeError
       FloatDomainError
     RegexpError
     RuntimeError
     SecurityError
     SystemCallError
     SystemStackError
     ThreadError
     TypeError
     ZeroDivisionError
   SystemExit
   fatal

   Custom Errors

# Potential Ideas
  * Headers, parse it like a README
  * Manifest to count number of types of errors are most common in your code, like a code coverage report

