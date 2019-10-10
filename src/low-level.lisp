;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package :trial-vr)

(defun sb->3d (matrix)
  "Convenience method to convert matrices from sb-cga to 3d-matrices.
   3b-openvr uses the former while Trial uses the latter."
  (if (typep matrix 'simple-array)
      (funcall #'3d-matrices:matn 4 4 (coerce matrix 'list))
      (3d-matrices:meye 4)))

(defun get-eye-pose (side)
  "Head to eye transform. Taken from 3b-openvr-hello."
  (vr::vr-system)
  (sb->3d (sb-cga:inverse-matrix (vr::get-eye-to-head-transform side))))

(defun get-eye-projection (side &key (near 0.3f0) (far 10000.0f0))
  "Returns the per eye projection matrix."
  (vr::vr-system)
  (sb->3d (vr::get-projection-matrix side near far)))

(let ((poses (make-array (list  vr::+max-tracked-device-count+) :initial-element 0)))
  (defun get-latest-hmd-pose ()
    (vr::vr-system)
    (vr::vr-compositor)
    (vr::wait-get-poses poses nil)
    (loop for device below vr::+max-tracked-device-count+
          for tracked-device = (aref poses device)
          when (getf tracked-device 'vr::pose-is-valid)
          do (setf (aref poses device) (getf tracked-device 'vr::device-to-absolute-tracking))
          finally (return (sb->3d (aref poses vr::+tracked-device-index-hmd+))))))