import { initCanvasAnimation } from './animations/canvas.js';

document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize generic background particles
    initCanvasAnimation();

    // 2. Set up Intersection Observer for triggering infographics
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.3 // Trigger when 30% of the section is visible
    };

    const sectionObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // Fade in the section
                entry.target.classList.add('visible');
                
                if (entry.target.id === 'cache-stampede') {
                    // CSS animations handle the rest when .visible is added
                }

                // Stop observing once visible
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe all infographic sections
    document.querySelectorAll('.infographic-section').forEach(section => {
        sectionObserver.observe(section);
    });

    // 3. Handle Sticky Navbar visibility using IntersectionObserver
    const stickyNav = document.getElementById('sticky-nav');
    const heroTitle = document.querySelector('.hero h1');
    
    if (stickyNav && heroTitle) {
        const navObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                // If the hero title is NOT intersecting and its bounding box is above the viewport (top < 0)
                if (!entry.isIntersecting && entry.boundingClientRect.bottom < 0) {
                    stickyNav.classList.add('scrolled');
                } else {
                    stickyNav.classList.remove('scrolled');
                }
            });
        }, {
            root: null,
            threshold: 0
        });
        
        navObserver.observe(heroTitle);
    }

    // 4. Handle Table of Contents (TOC) Highlighting
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

    // 5. Scroll to Top Button Logic
    const scrollTopBtn = document.getElementById('scrollTopBtn');
    if (scrollTopBtn) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 500) {
                scrollTopBtn.classList.add('visible');
            } else {
                scrollTopBtn.classList.remove('visible');
            }
        });

        scrollTopBtn.addEventListener('click', () => {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
});
