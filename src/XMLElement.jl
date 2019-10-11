# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# LSLXMLElement.jl: type and method definitions for steram information descriptors

import Base.unsafe_convert

export LSLXMLElement
export first_child, last_child, child, next_sibling, parent
export empty, is_text, value, child_value
export append_child_value, prepend_child_value, set_child_value, set_name, set_value, 
       append_child, prepend_child, append_copy, prepend_copy, remove_child
"""
LSLXMLElement

The LSLXMLElement type allows manipulation of the stream description of a StreamInfo type.
"""
struct LSLXMLElement
  handle::lib.lsl_xml_ptr

  function LSLXMLElement(handle) where T
    if handle != C_NULL
      elem = new(handle)
    else
      error("LSLXMLElement is nonexistent (library returned NULL pointer")
    end
    return elem
  end

end

# Define conversion to pointer
unsafe_convert(::Type{lib.lsl_xml_ptr}, elem::LSLXMLElement) = elem.handle

#
# Navigation
#

"""first_child(elem) return the first child of the element"""
first_child(elem::LSLXMLElement) = LSLXMLElement(lib.lsl_first_child(elem))

"""last_child(elem) return the last child of the element"""
last_child(elem::LSLXMLElement) = LSLXMLElement(lib.lsl_last_child(elem))

"""child(elem, name) return child of the element with specified name"""
child(elem::LSLXMLElement, name::String) = LSLXMLElement(lib.lsl_child(elem, name))

"""next_sibling(elem) return the next sibling in the children list of the parent node."""
next_sibling(elem::LSLXMLElement) = LSLXMLElement(lib.lsl_next_sibling(elem))

"""next_sibling(elem, name) return next sibling with given name"""
next_sibling(elem::LSLXMLElement, name::String) = LSLXMLElement(lib.lsl_next_sibling_n(elem, name))

"""previous_sibling(elem) return the previous sibling in the children list of the parent node."""
previous_sibling(elem::LSLXMLElement) = LSLXMLElement(lib.lsl_previous_sibling(elem))

"""previous_sibling(elem, name) return previous sibling with given name"""
previous_sibling(elem::LSLXMLElement, name::String) = LSLXMLElement(lib.lsl_previous_sibling_n(elem, name))

"""parent(elem) return the parent node of the element"""
parent(elem::LSLXMLElement) = LSLXMLElement(lib.lsl_parent(elem))
    
#
# Content query
#

"""empty(elem) return if element is empty."""
empty(elem::LSLXMLElement) = lib.lsl_empty(elem) == 0 ? false : true
    
"""is_text(elem) return if element is a text body, true both for plain char data and CData."""
is_text(elem::LSLXMLElement) = lib.lsl_is_text(elem) == 0 ? false : true

"""name(elem) return name of element"""
name(elem::LSLXMLElement) = unsafe_string(lib.lsl_name(elem))

"""value(elem) return value of the element"""
value(elem::LSLXMLElement) = unsafe_string(lib.lsl_value(elem))

"""child_vale(elem) retrun value of first child that is text
   child_vale(elem, name) retrun value of first child with the given name
"""
child_value(elem::LSLXMLElement) = unsafe_string(lib.child_value(elem))

child_value(elem::LSLXMLElement, name::String) = unsafe_string(lib.child_value(elem), name)

#
# Modificaiton
#

"""append_child_value(elem, name, value) append a child node with a given name, which has a
(nameless) plain-text child with the given text value."""
function append_child_value(elem::LSLXMLElement, name::String, value)
  return LSLXMLElement(lib.lsl_append_child_value(elem, name, string(value)))
end

"""prepend_child_value(elem, name, value) prepend a child node with a given name, which has 
a (nameless) plain-text child with the given text value."""
function prepend_child_value(elem::LSLXMLElement, name::String, value)
  return LSLXMLElement(lib.lsl_prepend_child_value(elem, name, string(value)))
end

"""set_child_value(elem, name, value) set the text value of the (nameless) plain-text child
of a named child node."""
function set_child_value(elem::LSLXMLElement, name::String, value)
  return LSLXMLElement(lib.lsl_set_child_value(elem, name, string(value)))
end

"""set_name(elem, name) set element's name, return false if node is empty."""
set_name(elem::LSLXMLElement, name::String) = lib.lsl_set_name(elem, name) == 0 ? false : true

"""set_value(elem, value) set the element's value, return false if the node is empty."""
set_value(elem::LSLXMLElement, value) = lib.lsl_set_value(elem, string(value)) == 0 ? false : true
  
"""append_child(elem, name) append a child element with the specified name."""
append_child(elem::LSLXMLElement, name::String) = LSLXMLElement(lib.lsl_append_child(elem, name))

"""prepend_child(elem, name) prepend a child element with the specified name."""
prepend_child(elem::LSLXMLElement, name::String) = LSLXMLElement(lib.lsl_prepend_child(elem, name))

"""append_copy(elem, elem_to) append a copy of `elem` as a child of `elem_to`"""
append_copy(elem::LSLXMLElement, elem_to::LSLXMLElement) = LSLXMLElement(lib.lsl_append_copy(elem, elem_to))

"""prepend_copy(elem, elem_to) prepend a copy of `elem` as a child of `elem_to`"""
prepend_copy(elem::LSLXMLElement, elem_to::LSLXMLElement) = LSLXMLElement(lib.lsl_prepend_copy(elem, elem_to))

"""remove_child(elem, elem_rm) remove child `elem_rm` from `elem`."""
remove_child(elem::LSLXMLElement, elem_rm::LSLXMLElement) = lib.lsl_remove_child(elem, elem_rm)

"""remove_child(elem, name) remove named child from `elem`."""
remove_child(elem::LSLXMLElement, name::String) = lib.lsl_remove_child_n(elem, name)


