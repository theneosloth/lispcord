(in-package :lispcord.util)

(defun str-concat (&rest strings)
  (apply #'concatenate 'string strings))

(defun jparse (payload)
  (jonathan:parse payload :as :alist))

(defun jmake (alist)
  (jonathan:to-json alist :from :alist))

(defun alist (car cdr &rest pairs)
  (if pairs
      (cons (cons car cdr)
	    (apply #'alist (car pairs) (cadr pairs) (cddr pairs)))
      (list (cons car cdr))))

(defun aget (key list)
  (cdr (assoc key list :test #'equal)))

(defmacro doit (&rest forms)
  (let ((it (intern (symbol-name 'it))))
    `(let (,it)
       ,@(mapcar (lambda (f)
		   (if (eq :! (car f))
		       (cdr f)
		       `(setf ,it ,f)))
		 forms))))

(defmacro str-case (key-form &body clauses &aux (key (gensym)))
  `(let ((,key ,key-form))
     (cond ,@(mapcar (lambda (c)
		       (if (string= (string (car c)) "ELSE")
			   `(T ,@(cdr c))
			   `((string= ,key ,(car c)) ,@(cdr c))))
		     clauses))))


;;; Set up a logging framework so bot authors can
;;;  gather various levels of information
(defparameter *debug-level* :info
  "The debug level can be one of: :error, :warn, :info, :debug")

(defvar *debug-levels*
  (alist :error (lambda (l) (case l (:error t)))
	 :warn (lambda (l) (case l ((:error :warn) t)))
	 :info (lambda (l) (case l ((:error :warn :info) t)))
	 :debug (lambda (l) (case l ((:error :warn :info :debug) t)))))

(defun set-log-level (level)
  (declare (type keyword level))
  (ecase level
    ((:info :error :warn :debug) (setf *debug-level* level))))


;;unfortunately "log" is package locked
(defun dprint (level message &rest arguments)
  (when (funcall (aget *debug-level* *debug-levels*) level)
    (apply #'format *error-output* message arguments)))
