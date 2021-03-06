/* eslint-disable class-methods-use-this */

import { ListItem as BaseListItem } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from '~/lib/prosemirror_markdown_serializer';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class ListItem extends BaseListItem {
  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.list_item(state, node);
  }
}
