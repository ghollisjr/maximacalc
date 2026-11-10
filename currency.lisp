;;; Currency exchange rates for phys.mac.
;;;
;;; Rates are the European Central Bank's daily reference rates (about
;;; 30 major currencies quoted against the euro, updated once per
;;; business day).  They are downloaded with curl and cached in the
;;; Maxima user directory; the cache is refreshed when it is more than
;;; a day old, and a stale cache is used if the download fails.
;;;
;;; Maxima functions provided:
;;;
;;;   currency_rates()        => [["USD", 1.08], ["JPY", 160.3], ...]
;;;                              (units of each currency per euro)
;;;   currency_rates(true)    => same, but forces a fresh download
;;;
;;; The variable currency_date is set to the date of the rates as a
;;; string, or false if no rates are available.

(in-package :maxima)

(defvar *currency-url*
  "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")

(defvar *currency-max-age* (* 24 60 60)
  "Seconds before the cached rates are considered stale.")

(defmvar $currency_date nil
  "Date of the currently loaded currency exchange rates.")

(defun currency-cache-file ()
  (concatenate 'string $maxima_userdir "/ecb_rates.xml"))

(defun currency-read-file (path)
  "Contents of the file as a string, or NIL if it cannot be read."
  (ignore-errors
   (with-open-file (in path :external-format :utf-8)
     (let* ((text (make-string (file-length in)))
            (n (read-sequence text in)))
       (subseq text 0 n)))))

(defun currency-attribute (name text start)
  "Value of the next NAME='...' attribute at or after START, plus the
position just past it.  NIL if there is none."
  (let* ((key (concatenate 'string name "='"))
         (i (search key text :start2 start)))
    (when i
      (let* ((s (+ i (length key)))
             (e (position #\' text :start s)))
        (when e
          (values (subseq text s e) (1+ e)))))))

(defun currency-parse-number (string)
  "Parse a plain decimal number, or NIL if STRING is anything else."
  (when (and (plusp (length string))
             (every (lambda (c) (or (digit-char-p c) (char= c #\.))) string)
             (some #'digit-char-p string)
             (<= (count #\. string) 1))
    (let ((*read-default-float-format* 'double-float)
          (*read-eval* nil))
      (float (read-from-string string) 1d0))))

(defun currency-parse (text)
  "Returns the list of (code rate) pairs found in the ECB XML and the
date they apply to."
  (let ((pos 0)
        (rates nil)
        (date (and text (currency-attribute "time" text 0))))
    (loop while text do
      (multiple-value-bind (code after-code)
          (currency-attribute "currency" text pos)
        (unless code (return))
        (multiple-value-bind (rate after-rate)
            (currency-attribute "rate" text after-code)
          (unless rate (return))
          (let ((number (currency-parse-number rate)))
            (when (and number (plusp number)
                       (= (length code) 3)
                       (every #'upper-case-p code))
              (push (list code number) rates)))
          (setf pos after-rate))))
    (values (nreverse rates) date)))

(defun currency-download (cache)
  "Download fresh rates into CACHE.  The cache is only replaced when
the download parses as a valid rate table.  Returns true on success."
  (let ((tmp (concatenate 'string cache ".tmp")))
    (ignore-errors
     (ensure-directories-exist cache)
     ($system (format nil "curl -s -f --connect-timeout 5 --max-time 8 ~
                           -o '~a' '~a' 2>/dev/null"
                      tmp *currency-url*))
     (prog1
         (when (currency-parse (currency-read-file tmp))
           (rename-file tmp cache)
           t)
       (when (probe-file tmp)
         (delete-file tmp))))))

(defun currency-cache-stale-p (cache)
  (let ((written (ignore-errors (file-write-date cache))))
    (or (null written)
        (> (- (get-universal-time) written) *currency-max-age*))))

(defun $currency_rates (&optional force)
  (let ((cache (currency-cache-file)))
    (when (or force (currency-cache-stale-p cache))
      (currency-download cache))
    (multiple-value-bind (rates date)
        (currency-parse (currency-read-file cache))
      (setf $currency_date (and rates date))
      (cons '(mlist)
            (mapcar (lambda (pair) (cons '(mlist) pair)) rates)))))
