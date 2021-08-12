# Supported annotations for the codegen system

## on a file
|Annotation|argc|Meaning|
|----------|----|-------|
@LinkWithLib|1|Link the corresponding C file with the specified library

## on a function
|Annotation|argc|Meaning|
|----------|----|-------|
@Show|1|Change the visible name of the generated function

## on an enum
None

## on a class
None

## on a class method
|Annotation|argc|Meaning|
|----------|----|-------|
Initializer|0|This method should be used to create structPointer. It will be called when the class is constructed using the default constructor.
Getter|1|This method will be generated as a getter using the given name.
Show|1|Same as on a function.
Invalidates|0|This method invalidates the pointer, probably by freeing memory. After it has been called, the pointer will be set to a nullptr, meaning any further operations on the class will raise an exception.