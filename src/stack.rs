#[derive(Debug)]
pub struct Stack<T> {
    stack: Vec<T>,
}

impl<T> Stack<T> {
    pub fn new() -> Self {
        Stack { stack: Vec::new() }
    }
    pub fn push(&mut self, val: T) {
        self.stack.push(val);
    }
    pub fn pop(&mut self) -> Option<T> {
        self.stack.pop()
    }
    pub fn size(&self) -> usize {
        self.stack.len()
    }
    pub fn empty(&self) -> bool {
        self.size() == 0
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    fn test() {
        let mut s = Stack::new();
        assert_eq!(s.size(), 0);
        assert!(s.empty());
        assert_eq!(s.pop(), None);
        s.push(1);
        assert!(!s.empty());
        assert_eq!(s.size(), 1); 
        s.push(2);
        assert_eq!(s.size(), 2);
        s.push(3); 
        assert_eq!(s.size(), 3);
        assert_eq!(s.pop(), Some(3));
        assert_eq!(s.pop(), Some(2));
        assert_eq!(s.pop(), Some(1));
        assert_eq!(s.pop(), None);
        assert_eq!(s.size(), 0);
        assert!(s.empty());
    }
}
