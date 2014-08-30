Q2D
===

A two-dimensional serial queue for NSOperations that supports quick and easy reordering,
prioritization, and cancellation of subqueues and processes while the queue is processing.

** What to use Q2D for **

- Long running processes that need to execute serially, which can be grouped
  into subcategories and may require reordering or modification after being added
  to the queue.

    - Example: downloading large files for several different sections of the app.

      Q2D can queue up all the downloads. Then based on user interaction, certain downloads
      can be prioritized over others.


Q2D currently only supports serial execution.
