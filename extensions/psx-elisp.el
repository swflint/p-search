;;; psx-elisp.el --- p-search candidate generator for emacs symbols  -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Samuel W. Flint

;; Author: Samuel W. Flint <me@samuelwflint.com>
;; Keywords: tools, lisp, help

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'p-search)

(p-search-def-field 'elisp-type 'category)

(defun psx-elisp--lighter (_)
  "Return Elisp Candidate Generator lighter."
  "ELISP")

(defun psx-elisp--name (id)
  "Compute the name for a symbol ID."
  (pcase-let ((`(,symbol ,type) id))
    (format "%s: %s" type symbol)))
(p-search-def-property 'elisp 'name #'psx-elisp--name)

(defun psx-elisp--fields (id)
  "Compute fields for item ID."
  (pcase-let ((`(_ ,type) id))
    (list (cons 'elisp-type (symbol-name type)))))
(p-search-def-property 'elisp 'fields #'psx-elisp--fields)

(defun psx-elisp--content (id)
  "Get documentation string for ID."
  (pcase-let ((`(,symbol ,type) id))
    (or (pcase type
          ('function
           (documentation symbol))
          ('variable
           (format "%s"
                   (or (get symbol 'variable-documentation)
                       (format "Variable `%s' not documented." symbol)))))
        "")))
(p-search-def-property 'elisp 'content #'psx-elisp--content)

(defun psx-elisp--candidate-generator (_args)
  "Generate elisp p-search candidates."
  (let (docs)
    (mapcar (lambda (symbol)
              (when (functionp symbol)
                (push (p-search-documentize (list 'elisp (list symbol 'function))) docs))
              (when (and (symbolp symbol)
                         (get symbol 'variable-documentation))
                (push (p-search-documentize (list 'elisp (list symbol 'variable))) docs)))
            obarray)
    docs))

(defconst psx-elisp-candidate-generator
  (p-search-candidate-generator-create
   :id 'psx-elisp-candidate-generator
   :name "ELISP"
   :function #'psx-elisp--candidate-generator
   :lighter-function #'psx-elisp--lighter))

(add-to-list 'p-search-candidate-generators psx-elisp-candidate-generator)

(provide 'psx-elisp)
;;; psx-elisp.el ends here
