use std::collections::VecDeque;

#[derive(Debug)]
pub struct Queue<T> {
    queue: VecDeque<T>,
}

impl<T> Queue<T> {
    pub fn new() -> Self {
        Queue { queue: VecDeque::new() }
    }
    pub fn push(&mut self, val: T) {
        self.queue.push_back(val);
    }
    pub fn pop(&mut self) -> Option<T> {
        self.queue.pop_front()
    }
    pub fn size(&self) -> usize {
        self.queue.len()
    }
    pub fn empty(&self) -> bool {
        self.size() == 0
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    fn test() {
        let mut q = Queue::new();
        assert_eq!(q.size(), 0);
        assert!(q.empty());
        assert_eq!(q.pop(), None);
        q.push(1);
        assert!(!q.empty());
        assert_eq!(q.size(), 1); 
        q.push(2);
        assert_eq!(q.size(), 2);
        q.push(3); 
        assert_eq!(q.size(), 3);
        assert_eq!(q.pop(), Some(1));
        assert_eq!(q.pop(), Some(2));
        assert_eq!(q.pop(), Some(3));
        assert_eq!(q.pop(), None);
        assert_eq!(q.size(), 0);
        assert!(q.empty());
    }
}
