1) Pre-document:
Made of key, value pairs. Allowed keys are: title, author, date

2) Document:
2.1) Section are delimited by ===. Example:
=== First Section ===
Note: we can not use = or == because these are valid mathematical symbols.

2.2) New slide (or new frame in beamer language) are delimited by ---. Example:
--- First Frame ---
Note: same as above - or -- are valid mathematical symbols so we have to use at least three. 

2.3) Items:
Bullet points start with *. Different levels are obtained based on spaces (or tabs). Example:
* item 1
  * item of second level

Enumerations is done with # and dotted integers. Example:
# enum 
  1. second level of enum
  2. second enum in the second level

2.4) Math: 
Like in latex it starts and ends with $. 
Example: $f(x) = x + 1$

2.5) Style:
italic is obtained with __: __this is in italic__

2.6) Code and verbatim:
Verbatim mode is triggered with:
\begin{verbatim}
int main(void) {
  return 0;
}
\end{verbatim}

2.7) Pictures:
Filename within square brackets []; the number before # corresponds to the picture scale to use
[10%pic.png] -> import pic.png with scale = 0.1
[20%pic.png] -> import pic.png with scale = 0.2
[pic.png] -> import pic.png with scale = 1.0


3) TODO
- allow for algorithms with suitable package
- allow for languages with suitable package
- tables
