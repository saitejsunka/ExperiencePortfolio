-- ---------------------------------------------------------
-- Posts Table (Single Table Design for Learning)
-- ---------------------------------------------------------

CREATE TABLE IF NOT EXISTS posts (
    post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL, -- Logical reference to a user
    content TEXT NOT NULL,
    media_urls TEXT[] DEFAULT '{}', -- Array of image/video URLs
    like_count INT DEFAULT 0,
    reply_count INT DEFAULT 0,
    repost_count INT DEFAULT 0,
    parent_post_id UUID, -- If this post is a reply to another post
    is_deleted BOOLEAN DEFAULT FALSE, -- Soft delete flag
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index to quickly find all posts by a specific user
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id);
