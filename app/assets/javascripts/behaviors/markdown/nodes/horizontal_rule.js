/* eslint-disable class-methods-use-this */

import { HorizontalRule as BaseHorizontalRule } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from '~/lib/prosemirror_markdown_serializer';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class HorizontalRule extends BaseHorizontalRule {
  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.horizontal_rule(state, node);
  }
}
