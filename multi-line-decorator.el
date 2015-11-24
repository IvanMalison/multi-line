;;; multi-line-decorator.el --- multi-line statements -*- lexical-binding: t; -*-

;; Copyright (C) 2015 Ivan Malison

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; multi-line-decorator defines a collection of decorator respacers
;; that can be used to add behavior to existing respacers.

;;; Code:

(require 'eieio)
(require 'multi-line-shared)

(defclass multi-line-decorator ()
  ((respacer :initarg :respacer)
   (decorator :initarg :decorator)))

(defmethod multi-line-respace ((decorator multi-line-decorator)
                               index markers)
  (funcall (oref decorator :decorator) (oref decorator :respacer) index markers))

(defmacro multi-line-pre-decorator (name &rest forms)
  "Build a constructor with name NAME that builds respacers that
execute FORMS before respacing.  FORMS can use the variables index
and markers which will be appropriately populated by the
executor."
  `(defun ,name (respacer)
     (make-instance
      multi-line-decorator
      :respacer respacer
      :decorator (lambda (respacer index markers)
                   ,@forms
                   (multi-line-respace respacer index markers)))))

(defmacro multi-line-post-decorator (name &rest forms)
  "Build a constructor with name NAME that builds respacers that
execute FORMS after respacing.  FORMS can use the variables index
and markers which will be appropriately populated by the
executor."
  `(defun ,name (respacer)
     (make-instance
      multi-line-decorator
      :respacer respacer
      :decorator (lambda (respacer index markers)
                   (multi-line-respace respacer index markers)
                   ,@forms))))

(multi-line-pre-decorator multi-line-space-clearing-respacer
                          (multi-line-clear-whitespace-at-point))

(multi-line-post-decorator multi-line-trailing-comma-respacer
                           (multi-line-add-trailing-comma index markers))

(provide 'multi-line-decorator)
;;; multi-line-decorator.el ends here
