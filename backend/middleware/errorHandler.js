const errorHandler = (err, req, res, next) => {
  const statusCode = err.status || 500;
  const isServerError = statusCode >= 500;

  if (isServerError) {
    // Full detail stays server-side only; never sent to the client.
    console.error(err);
  }

  const message =
    isServerError && process.env.NODE_ENV === 'production'
      ? 'Internal Server Error'
      : err.message || 'Internal Server Error';
  const errors = err.errors || null;

  res.status(statusCode).json({
    success: false,
    message,
    errors,
  });
};

module.exports = errorHandler;
