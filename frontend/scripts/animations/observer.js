/**
 * Uses IntersectionObserver to trigger animations when elements scroll into view.
 */
export function initScrollObserver() {
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.2 // Trigger when 20% of the element is visible
    };

    const observer = new IntersectionObserver((entries, obs) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // Add visible class to trigger CSS animations
                entry.target.classList.add('visible');
                
                // If it's a timeline item, mark it active
                if (entry.target.classList.contains('timeline-item')) {
                    entry.target.classList.add('active');
                }
                
                // Stop observing once animated to prevent repeating
                obs.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe all glass cards and bento grid items
    document.querySelectorAll('.glass-card, .bento-item').forEach(el => observer.observe(el));
    
    // Observe all timeline items
    document.querySelectorAll('.timeline-item').forEach(el => observer.observe(el));

    // Handle Timeline Progress Line Scrubbing
    const progressLine = document.getElementById('timelineProgress');
    if (progressLine) {
        window.addEventListener('scroll', () => {
            // Calculate how far down we've scrolled relative to the document
            const scrolled = window.scrollY;
            const maxScroll = document.documentElement.scrollHeight - window.innerHeight;
            
            if (maxScroll > 0) {
                // We want the line to grow as we scroll down
                const scrollFraction = Math.min(scrolled / (maxScroll * 0.8), 1); // 0.8 to complete line before hitting rock bottom
                progressLine.style.transform = `scaleY(${scrollFraction})`;
            }
        });
    }

    // Handle Sticky Navbar visibility
    const stickyNav = document.getElementById('sticky-nav');
    const heroTitle = document.querySelector('.hero h1');
    
    if (stickyNav && heroTitle) {
        window.addEventListener('scroll', () => {
            // When the hero title is scrolled out of the viewing range, show the navbar
            if (heroTitle.getBoundingClientRect().bottom < 0) {
                stickyNav.classList.add('scrolled');
            } else {
                stickyNav.classList.remove('scrolled');
            }
        });
    }

    // Handle Table of Contents (TOC) Highlighting
    const tocObserverOptions = {
        root: null,
        rootMargin: '-30% 0px -60% 0px', // Trigger when section is in the middle-top part of the screen
        threshold: 0
    };

    const tocObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const id = entry.target.getAttribute('id');
                // Remove active class from all toc-links
                document.querySelectorAll('.toc-link').forEach(link => {
                    link.classList.remove('active');
                });
                
                // Add active class to corresponding link
                const activeLink = document.querySelector(`.toc-link[href="#${id}"]`);
                if (activeLink) {
                    activeLink.classList.add('active');
                }
            }
        });
    }, tocObserverOptions);

    // Observe all infographic sections for TOC
    document.querySelectorAll('.infographic-section').forEach(section => {
        tocObserver.observe(section);
    });
}
